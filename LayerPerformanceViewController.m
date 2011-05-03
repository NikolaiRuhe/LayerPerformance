//
//  LayerPerformanceViewController.m
//  LayerPerformance
//
//  Created by Nikolai Ruhe on 01.05.11.
//  Copyright 2011 Savoy Software. All rights reserved.
//

#import "LayerPerformanceViewController.h"
#import <QuartzCore/QuartzCore.h>

#define DRAGGABLE_VIEWS_COUNT 30


@interface LayerPerformanceViewController()
@property (nonatomic) BOOL lightweight;
- (void)updateLinesForView:(UIView *)draggableView;
- (void)toggleMode;
@end



@implementation LayerPerformanceViewController

@synthesize window = _window;
@synthesize container = _container;
@synthesize lightweight = _lightweight;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window.rootViewController = self;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)toggleMode:(UIButton *)toggleButton
{
    [self toggleMode];
    [toggleButton setTitle:self.lightweight ? @"Core Animation" : @"Core Graphics"
                  forState:UIControlStateNormal];
}

- (void)loadView
{
    self.container = [[[UIView alloc] init] autorelease];
    self.container.bounds = (CGRect){ {0, 0}, {768, 1024} };
    self.container.backgroundColor = [UIColor whiteColor];
    self.container.opaque = YES;
    self.container.center = (CGPoint){ 384, 512 };

    self.view = [[[UIView alloc] init] autorelease];
    self.view.bounds = (CGRect){ {0, 0}, {768, 1024} };
    [self.view addSubview:self.container];

    UIButton *toggleButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    toggleButton.frame = (CGRect){{620, 10},{130, 32}};
    [toggleButton addTarget:self
                     action:@selector(toggleMode:)
           forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:toggleButton];

    for (NSUInteger idx = 0; idx < DRAGGABLE_VIEWS_COUNT; ++idx) {
        CGPoint position = { random() % 728 + 20, random() % 984 + 20};
        UIView *draggableView = [[[UIView alloc] init] autorelease];
        draggableView.bounds = (CGRect){{0, 0},{40, 40}};
        draggableView.center = position;
        CALayer *draggableLayer = draggableView.layer;
        draggableLayer.cornerRadius = 20;
        draggableLayer.sublayerTransform = CATransform3DMakeTranslation(20, 20, 0);
        [self.container addSubview:draggableView];
        UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(didDragView:)];
        [draggableView addGestureRecognizer:gestureRecognizer];
        for (NSUInteger i = 0; i < idx; ++i) {
            CALayer *lineLayer = [CALayer layer];
            lineLayer.opacity = 0.2;
            [draggableLayer addSublayer:lineLayer];
        }

        [self updateLinesForView:draggableView];
    }

    [self toggleMode:toggleButton];
}

static void setLayerToLineFromAToB(CALayer *layer, CGPoint a, CGPoint b, CGFloat lineWidth)
{
    CGPoint center = { 0.5 * (a.x + b.x), 0.5 * (a.y + b.y) };
    CGFloat length = sqrt((a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y));
    CGFloat angle = atan2(a.y - b.y, a.x - b.x);
    
    layer.position = center;
    layer.bounds = (CGRect) { {0, 0}, { length + lineWidth, lineWidth } };
    layer.transform = CATransform3DMakeRotation(angle, 0, 0, 1);
}

- (void)toggleMode
{
    [CATransaction setDisableActions:YES];
    self.lightweight = ! self.lightweight;
    for (UIView *draggableView in self.container.subviews) {
        draggableView.backgroundColor = self.lightweight ? [UIColor orangeColor] : [UIColor blueColor];
        for (CALayer *lineLayer in draggableView.layer.sublayers) {
            if (self.lightweight) {
                lineLayer.contents = nil;
                lineLayer.backgroundColor = [UIColor orangeColor].CGColor;
                lineLayer.delegate = nil;
            } else {
                lineLayer.transform = CATransform3DIdentity;
                lineLayer.backgroundColor = NULL;
                lineLayer.delegate = self;
            }
        }
    }
    [CATransaction setDisableActions:NO];
    for (UIView *draggableView in self.container.subviews) {
        [self updateLinesForView:draggableView];
    }
}

- (void)updateLinesForView:(UIView *)draggableView
{
    [CATransaction setDisableActions:YES];
    NSArray *draggableViews = draggableView.superview.subviews;
    NSArray *lineLayers = draggableView.layer.sublayers;
    NSUInteger viewIndex = [draggableViews indexOfObject:draggableView];
    CGPoint pos = draggableView.center;
    
    for (NSUInteger i = 0; i < [lineLayers count]; ++i) {
        CALayer *lineLayer = [lineLayers objectAtIndex:i];
        CGPoint target = ((UIView *)[draggableViews objectAtIndex:i]).center;
        target.x -= pos.x;
        target.y -= pos.y;
        if (self.lightweight) {
            setLayerToLineFromAToB(lineLayer, CGPointZero, target, 8);
        } else {
            lineLayer.frame = (CGRect){ { target.x < 0 ? target.x : 0, target.y < 0 ? target.y : 0 }, { fabs(target.x), fabs(target.y) } };
            [lineLayer setValue:[NSNumber numberWithBool:(target.x < 0) ^ (target.y < 0)] forKey:@"alternate"];
            [lineLayer setNeedsDisplay];
        }
    }
    
    for (NSUInteger i = viewIndex + 1; i < [draggableViews count]; ++i) {
        UIView *otherDraggableView = [draggableViews objectAtIndex:i];
        CALayer *lineLayer = [otherDraggableView.layer.sublayers objectAtIndex:viewIndex];
        CGPoint target = otherDraggableView.center;
        target.x = pos.x - target.x;
        target.y = pos.y - target.y;
        if (self.lightweight) {
            setLayerToLineFromAToB(lineLayer, CGPointZero, target, 8);
        } else {
            lineLayer.frame = (CGRect){ { target.x < 0 ? target.x : 0, target.y < 0 ? target.y : 0 }, { fabs(target.x), fabs(target.y) } };
            [lineLayer setValue:[NSNumber numberWithBool:(target.x < 0) ^ (target.y < 0)] forKey:@"alternate"];
            [lineLayer setNeedsDisplay];
        }
    }
    [CATransaction setDisableActions:NO];
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    if (self.lightweight)
        return;
    if ([[layer valueForKey:@"alternate"] boolValue]) {
        CGContextMoveToPoint(ctx, layer.bounds.size.width, 0);
        CGContextAddLineToPoint(ctx, 0, layer.bounds.size.height);
    } else {
        CGContextMoveToPoint(ctx, 0, 0);
        CGContextAddLineToPoint(ctx, layer.bounds.size.width, layer.bounds.size.height);
    }
    CGContextSetStrokeColorWithColor(ctx, [UIColor blueColor].CGColor);
    CGContextSetLineWidth(ctx, 8);
    CGContextStrokePath(ctx);
}

- (void)didDragView:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint translation = [gestureRecognizer translationInView:self.container];
    [gestureRecognizer setTranslation:CGPointZero inView:self.container];
    CGPoint center = gestureRecognizer.view.center;
    gestureRecognizer.view.center = (CGPoint){ center.x + translation.x, center.y + translation.y };
    [self updateLinesForView:gestureRecognizer.view];
}

@end

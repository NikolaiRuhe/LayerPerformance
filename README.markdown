LayerPerformance
================

This project illustrates the ideas presented in [this stackoverflow post](http://stackoverflow.com/questions/5847876/whats-the-best-approach-to-draw-lines-between-views/5848118#5848118).

It is a simple iPad app intended to measure the difference between Core Graphics rendering and Core Animation (layer based) rendering. The app shows a number of draggable dots, connected by lines. When a dot is moved, the connected lines are updated to follow the dot. There are two implementations with vastly different performance and memory consumption: Core Graphics and Core Animation.

![screenshot and instruments results](http://i.stack.imgur.com/vqNwO.png)

### Core Graphics

Core Graphics is used to create the lines. The layer is extended to the bounding
box of the line. The contents are drawn using Core Graphics functions.

### Core Animation

The layer is filled with the line color and resized, positioned and rotated to
exactly cover the area of the line. No CPU based redraw is needed for this drawing
mode.

As expected, the performance of Core Animation based drawing is drastically better
than for Core Graphics based drawing. Also, the memory footprint is considerably
lower.
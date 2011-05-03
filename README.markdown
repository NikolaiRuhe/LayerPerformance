LayerPerformance
================

LayerPerformance is a simple iPad project intended to measure the difference
between Core Graphics rendering and Core Animation (layer based) rendering.

It shows a number of draggable dots, connected by lines. When a dot is moved,
the connected lines are updated to follow the dot.

This is done in one of two ways:

Core Graphics
-------------

Core Graphics is used to create the lines. The layer is extended to the bounding
box of the line. The contents are drawn using Core Graphics functions.

Core Animation
--------------

The layer is filled with the line color and resized, positioned and rotated to
exactly cover the area of the line. No CPU based redraw is needed for this drawing
mode.

As expected, the performance of Core Animation based drawing is drastically better
than for Core Graphics based drawing. Also, the memory footprint is considerably
lower.
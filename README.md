# camera_movement_emulator
Matlab code to create artificial camera movement (e.g. hand shake) sequence from an input image.

Matlab code for the mosaic generation and evaluation framesworks introduced in
 * Image Based Quantitative Mosaic Evaluation with Artificial Video (P. Paalanen, J.-K. Kamarainen and H. Kälviäinen), In Scandinavian Conf. on Image Analysis (SCIA2009), 2009. [PDF](https://webpages.tuni.fi/vision/data/publications/scia2009_mosaic.pdf)

Authors:
 * [Pekka Paalanen](https://ppaalanen.blogspot.com/) - Original code for the publication
 * [Joni Kamarainen](https://github.com/kamarain/) - "Refreshed" old code for this repo

## Interactive demo

With the interactive demo you can generate a sequence of artificial video define by manually entered path
that includes image center points and camera angles. Just run

```
$ nice matlab -nodesktop -softwareopengl
>> addpath tools
>> demo_interactive_conf
>> demo_interactive
```

and the demo will instruct you through. The code helps you to understand the functionality where the main generation code
is in *computerframes2d.m*

![Interactive demo](data/camera_movement_emulator_framework.png)

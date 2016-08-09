# SVGA v3
A framework for making interactive animations with SVG.

### [Starter Project](https://github.com/cdig/svg-activity-starter) • [Issues](https://github.com/cdig/svga/issues) • [Wiki](https://github.com/cdig/svga/wiki)

## Todos:

Tuesday
* Figure out the right way to deal with mouse VS touch
  * Defer firing Input mouse handlers until the end of the event loop, when we know whether a touch event also fired?
  * What are all possible states/transitions?
    NAME          CHANGED    BUTTON    POSITION  LOCATION
    down          button     up->down  p         in
    up            button     down->up  p         in
    move          position   up        p->p'     in
    drag          position   down      p->p'     in
    moveOut       location   up        p         in->out
    dragOut       location   down      p         in->out
    downOther     button     up->down  p         out
    upOther       button     down->up  p         out
    moveOther     position   up        p->p'     out
    dragOther     position   down      p->p'     out
    moveIn        location   up        p         out->in
    dragIn        location   down      p         out->in
    

Slider drags are slow on iPad. Is it because..
  we have to detect whether the slider drag is affecting nav by doing a DOM query?
  events are firing really quickly and something is doing too much work?
    should we pool events into a queue, then later dedupe and act on them?
      

Tuesday Evening
* Schematic button
* Other GUI stuff
* Background Color
* Clean up SVGA Components, Background, Help
* Gradients

Later
* SVGA in cd-module
* New BakeLines
* Enable Uglify
* Manifold backgrounds?
* No scrolling controls on height — just make the panel wider
* Pause
* Vertical slider
* POIs should be defined as a rect
* Mouse wheel doesn't zoom?
* Full-screen?

## License
Copyright (c) 2014-2016 CD Industrial Group Inc. http://www.cdiginc.com

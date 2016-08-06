gulp = require "gulp"
gulp_replace = require "gulp-replace"

gulp.task "default", ()->
  gulp.src "source/**/*.coffee"

    # Cleanup the Take
    .pipe gulp_replace /[^]*?Take.*\)->/g, 'Take ["Pressure", "Symbol"], (Pressure, Symbol)->'
    
    # Collapse the registerInstance calls into 1 line
    .pipe gulp_replace /activity.registerInstance\((.+,\s?).+\s*/mg, "registerInstance$1"
    
    # Move the registerInstance calls up to the top
    .pipe gulp_replace /(activity.([^]+?)\s?)=\s?([^]+?)(registerInstance[^]+)/mg, "Symbol \"$2\", [$4], $3"
    
    # Cleanup registerInstance
    .pipe gulp_replace /registerInstance/g, ""
    .pipe gulp_replace /,\s*?],/g, "],"

    # General
    .pipe gulp_replace "scope.", "@"
    .pipe gulp_replace /(.*enableHydraulicLines.*)/g, "#X $1"
    .pipe gulp_replace /animation:(.*)/g, "animate:$1 #X"
    .pipe gulp_replace /.*=.*SVGAnimation.*/g, "#X"
    .pipe gulp_replace /SVGAnimation\s?/g, ""
    .pipe gulp_replace "SVGMask", "#X Mask"
    .pipe gulp_replace "@global.", "#X @global."
    .pipe gulp_replace "PointerInput", "#X Input"
    .pipe gulp_replace "@root.FlowArrows", "FlowArrows"
    .pipe gulp_replace "@FlowArrows", "FlowArrows"
    .pipe gulp_replace ".getElement()", ".element"
    .pipe gulp_replace "style.", ""
    .pipe gulp_replace "transform.", ""
    .pipe gulp_replace ".angle", ".rotation"
    .pipe gulp_replace "FlowArrows.hide()", "#X FlowArrows.hide()"
    .pipe gulp_replace "FlowArrows.scale", "FlowArrows.SCALE"
    .pipe gulp_replace "FlowArrows.start()", "#X FlowArrows.start()"
    .pipe gulp_replace /FlowArrows\.setup\(.+?,\s*?/, "FlowArrows.setup("
    .pipe gulp_replace /([@.])visible\((.+?)\)/g, "$1alpha = $2"
    .pipe gulp_replace /\.setPressure\((.+?)\)/g, ".pressure = $1"
    .pipe gulp_replace /\.getPressure\(\)/g, ".pressure"
    .pipe gulp_replace /\.setColor\(HydraulicPressure\((.*?)\)\)/g, ".pressure = $1"
    .pipe gulp_replace /getElement:\s*?\(\)->[^]*?svgElement[^]*?(\S)/gm, "$1"
    .pipe gulp_replace "svgElement", "element"
    
    # Overwrite the original file
    .pipe gulp.dest "source"

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
    .pipe gulp_replace "animation:", "animate:"
    .pipe gulp_replace /.*=.*SVGAnimation.*/g, ""
    .pipe gulp_replace /SVGAnimation\s?/g, ""
    .pipe gulp_replace "SVGMask", "# Mask"
    .pipe gulp_replace "PointerInput", "# PointerInput"
    .pipe gulp_replace "@root.FlowArrows", "FlowArrows"
    .pipe gulp_replace "@FlowArrows", "FlowArrows"
    .pipe gulp_replace ".getElement()", ".element"
    .pipe gulp_replace "stroke:", "setDisplacement:"
    .pipe gulp_replace ".style.", "."
    .pipe gulp_replace ".transform.", "."
    .pipe gulp_replace ".angle", ".rotation"
    .pipe gulp_replace "FlowArrows.hide()", ""
    .pipe gulp_replace "FlowArrows.scale", "FlowArrows.SCALE"
    .pipe gulp_replace "FlowArrows.start()", ""
    .pipe gulp_replace /FlowArrows\.setup\(.+?,\s*?/, "FlowArrows.setup("
    .pipe gulp_replace /\.visible\((.+?)\)/g, ".alpha = $1"
    .pipe gulp_replace /\.setPressure\((.+?)\)/g, ".pressure = $1"
    .pipe gulp_replace /\.getPressure\(\)/g, ".pressure"
    .pipe gulp_replace /\.setColor\(HydraulicPressure\((.*?)\)\)/g, ".pressure = $1"
    .pipe gulp_replace /getElement:\s*?\(\)->[^]*?svgElement[^]*?(\S)/gm, "$1"
    
    
    .pipe gulp.dest "source" # overwrite the original file with optimized, pretty-printed version

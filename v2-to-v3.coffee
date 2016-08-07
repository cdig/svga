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

    ###############################################################################################
    
    # This name causes conflicts
    .pipe gulp_replace /stroke:(.*)/, "setDisplacement:$1 #X Renamed stroke->setDisplacement, because stroke is a reserved word"
    
    # These behviours have changed
    .pipe gulp_replace /animation:(.*)/g, "animate:$1 #X Renamed animation->animate"
    .pipe gulp_replace /scope.animation\.(.*)/g, "#X scope.animate.$2 #X No longer necessary"
    
    # These properties have been collapsed
    .pipe gulp_replace ".style.", "."
    .pipe gulp_replace ".transform.", "."
    
    # These properties have been renamed
    .pipe gulp_replace ".angle", ".rotation"
    
    # These functions are now properties
    .pipe gulp_replace /\.visible\((.+?)\)/g, "$1alpha = $2"
    .pipe gulp_replace /\.setPressure\((.+?)\)/g, ".pressure = $1"
    .pipe gulp_replace ".getPressure()", ".pressure"
    .pipe gulp_replace /\.setColor\(HydraulicPressure\((.*?)\)\)/g, ".pressure = $1"
    
    # These have been removed
    .pipe gulp_replace "SVGMask", "#X SVGMask"
    .pipe gulp_replace "PointerInput", "#X PointerInput"
    .pipe gulp_replace /scope\.global\.(.*)/, "#X scope.global.$1 #X scope.global has been removed"
    .pipe gulp_replace /(.*enableHydraulicLines.*)/g, "#X $1 #X This behaviour has changed"
    .pipe gulp_replace /.*=.*SVGAnimation.*/g, "#X Removed SVGAnimation"
    .pipe gulp_replace /SVGAnimation\s?(.*)/g, "$1 #X Removed SVGAnimation"
    
    # Normalize element references
    .pipe gulp_replace /getElement:\s*?\(\)->[^]*?svgElement[^]*?(\S)/gm, "$1"
    .pipe gulp_replace "getElement()", "element"
    .pipe gulp_replace "svgElement", "element"

    # scope -> @ ##################################################################################
    .pipe gulp_replace "scope.", "@"
    
    # Clean up FlowArrows
    .pipe gulp_replace "@root.FlowArrows", "FlowArrows"
    .pipe gulp_replace "@FlowArrows", "FlowArrows"
    .pipe gulp_replace "FlowArrows.hide()", "#X FlowArrows.hide()"
    .pipe gulp_replace "FlowArrows.scale", "FlowArrows.SCALE"
    .pipe gulp_replace "FlowArrows.start()", "#X FlowArrows.start()"
    .pipe gulp_replace /FlowArrows\.setup\(.+?,\s*?/, "FlowArrows.setup("
    
    ###############################################################################################
    
    # Overwrite the original file
    .pipe gulp.dest "source"

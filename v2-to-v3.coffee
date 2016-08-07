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
    .pipe gulp_replace /stroke:(.*)/g, "setDisplacement:$1 #X Renamed stroke->setDisplacement, because stroke is a reserved word"
    .pipe gulp_replace /scope(.*)stroke(.*)/g, "scope$1stroke$2 #X Warning: stroke might need to be changed to setDisplacement"
    
    # These behviours have changed
    .pipe gulp_replace /animation:(.*)/g, "animate:$1 #X Renamed animation->animate"
    .pipe gulp_replace /scope(.*)animation(.*)/g, "null # scope$1animate$2 #X scope.animate has changed meaning - revise accordingly"
    .pipe gulp_replace /scope(.*)update(.*)/g, "null # scope$1update$2 #X scope.update has changed meaning - revise accordingly"
    .pipe gulp_replace /scope(.*)ctrlPanel(.*)/g, "null # scope$1ctrlPanel$2 #X ctrlPanel has been removed"
    
    # Pressure is now easier to use
    .pipe gulp_replace "vacuumPressure: -2", ""
    .pipe gulp_replace "drainPressure: 0", ""
    .pipe gulp_replace "minPressure: 1", ""
    .pipe gulp_replace "medPressure: 50", ""
    .pipe gulp_replace "maxPressure: 100", ""
    .pipe gulp_replace "scope.vacuumPressure", "Pressure.vacuum"
    .pipe gulp_replace "scope.drainPressure", "Pressure.drain"
    .pipe gulp_replace "scope.minPressure", "Pressure.min"
    .pipe gulp_replace "scope.medPressure", "Pressure.med"
    .pipe gulp_replace "scope.maxPressure", "Pressure.max"
    
    # These properties have been collapsed
    .pipe gulp_replace ".style.", "."
    .pipe gulp_replace ".transform.", "."
    
    # These properties have been renamed
    .pipe gulp_replace ".angle", ".rotation"
    
    # These functions are now properties
    .pipe gulp_replace /\.visible\((.+?)\)/g, ".alpha = $1"
    .pipe gulp_replace /\.setPressure\((.+?)(, 1)?\)/g, ".pressure = $1"
    .pipe gulp_replace ".getPressure()", ".pressure"
    .pipe gulp_replace /scope(.*)getPressureColor()(.*)/, "# scope$1getPressureColor$2 #X getPressureColor() has been removed. Use .pressure instead."
    .pipe gulp_replace /\.setColor\(HydraulicPressure\((.*?)\)\)/g, ".pressure = $1"
    
    # These have been removed
    .pipe gulp_replace "SVGMask", "#X SVGMask"
    .pipe gulp_replace "PointerInput", "#X PointerInput"
    .pipe gulp_replace /scope\.global\.(.*)/g, "#X scope.global.$1 #X scope.global has been removed"
    .pipe gulp_replace /(.*enableHydraulicLines.*)/g, "# $1 #X This behaviour has changed"
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
    .pipe gulp_replace "FlowArrows.hide()", "# FlowArrows.hide() #X No longer necessary"
    .pipe gulp_replace "FlowArrows.scale", "FlowArrows.SCALE"
    .pipe gulp_replace "FlowArrows.start()", "# FlowArrows.start() #X No longer necessary"
    .pipe gulp_replace /FlowArrows\.setup\(.+?,\s*?/g, "FlowArrows.setup("
    .pipe gulp_replace /flowArrowsData.?=[^]+?edges:\[\[([^]+?)(@.*?)FlowArrows.setup.*?@(.*?)\..*/gm, "$2FlowArrows @$3, $1"
    .pipe gulp_replace /(Take \[)(.*)\(([^]*FlowArrows)/, "$1\"FlowArrows\", $2(FlowArrows, $3"
    
    # Convert Flow Arrows from the old BakeLines form to the new BakeLines form
    .pipe gulp_replace /\]\]}[^]*\[\[/gm, ","
    .pipe gulp_replace /\]\]}\);/g, ""
    .pipe gulp_replace /\], \[/g, ","
    .pipe gulp_replace /({x: .+?, y: .+?}.?){3}/g, "$&xxx"
    .pipe gulp_replace /({x: .+?, y: .+?},){x: .+?, y: .+?},({x: .+?, y: .+?},?)xxx/g, "$1$2"
    
    ###############################################################################################
    
    # Overwrite the original file
    .pipe gulp.dest "source"

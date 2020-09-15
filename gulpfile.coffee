fs = require "fs"
gulp = require "gulp"
gulp_autoprefixer = require "gulp-autoprefixer"
gulp_coffee = require "gulp-coffee"
gulp_concat = require "gulp-concat"
gulp_natural_sort = require "gulp-natural-sort"
gulp_sass = require "gulp-sass"


# CONFIG ##########################################################################################


paths =
  coffee: "source/**/*.coffee"
  scss: [
    "lib/_vars.scss"
    "source/**/*.scss"
  ]
  static: "source/index.html"


# HELPER FUNCTIONS ################################################################################


logAndKillError = (err)->
  console.log "\n## Error ##"
  console.log err.toString() + "\n"
  @emit "end"


# TASKS: COMPILATION #######################################################################  #####


gulp.task "coffee", ()->
  gulp.src paths.coffee
    .pipe gulp_natural_sort()
    .pipe gulp_concat "svga.coffee"
    .pipe gulp_coffee()
    .on "error", logAndKillError
    .pipe gulp.dest "dist"


gulp.task "static", ()->
  gulp.src paths.static
    .pipe gulp.dest "dist"


gulp.task "scss", ()->
  gulp.src paths.scss
    .pipe gulp_natural_sort()
    .pipe gulp_concat "svga.scss"
    .pipe gulp_sass
      precision: 2
    .pipe gulp_autoprefixer
      cascade: false
      remove: false
    .on "error", logAndKillError
    .pipe gulp.dest "dist"


# TASKS: SYSTEM ###################################################################################


gulp.task "watch", (cb)->
  gulp.watch paths.coffee, gulp.series "coffee"
  gulp.watch paths.static, gulp.series "static"
  gulp.watch paths.scss, gulp.series "scss"
  cb()


gulp.task "compile",
  gulp.series "coffee", "static", "scss"


gulp.task "default",
  gulp.series "compile", "watch"

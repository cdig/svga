del = require "del"
gulp = require "gulp"
gulp_coffee = require "gulp-coffee"
gulp_concat = require "gulp-concat"
gulp_natural_sort = require "gulp-natural-sort"
gulp_notify = require "gulp-notify"
gulp_sass = require "gulp-sass"


# CONFIG ##########################################################################################


paths =
  coffee: "source/**/*.coffee"
  html: "source/index.html"
  scss: "source/**/*.scss"


gulp_notify.logLevel(0)


# HELPER FUNCTIONS ################################################################################


logAndKillError = (err)->
  console.log "\n## Error ##"
  console.log err.toString() + "\n"
  gulp_notify.onError(
    emitError: true
    icon: false
    message: err.message
    title: "👻"
    wait: true
    )(err)
  @emit "end"


# TASKS: COMPILATION #######################################################################  #####


gulp.task "coffee", ()->
  gulp.src paths.coffee
    .pipe gulp_natural_sort()
    .pipe gulp_concat "svga.coffee"
    .pipe gulp_coffee()
    .on "error", logAndKillError
    .pipe gulp.dest "dist"


gulp.task "html", ()->
  gulp.src paths.html
    .pipe gulp.dest "dist"


gulp.task "scss", ()->
  gulp.src paths.scss
    .pipe gulp_natural_sort()
    .pipe gulp_concat "svga.scss"
    .pipe gulp_sass
      errLogToConsole: true
      outputStyle: "compressed"
      precision: 2
    .on "error", logAndKillError
    .pipe gulp.dest "dist"


# TASKS: SYSTEM ###################################################################################


gulp.task "del:dist", ()->
  del "dist"


gulp.task "watch", (cb)->
  gulp.watch paths.coffee, gulp.series "coffee"
  gulp.watch paths.html, gulp.series "html"
  gulp.watch paths.scss, gulp.series "scss"
  cb()


gulp.task "compile",
  gulp.series "del:dist", "coffee", "html", "scss"


gulp.task "default",
  gulp.series "compile", "watch"

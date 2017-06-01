fs = require "fs"
gulp = require "gulp"
gulp_coffee = require "gulp-coffee"
gulp_concat = require "gulp-concat"
gulp_natural_sort = require "gulp-natural-sort"
gulp_notify = require "gulp-notify"
gulp_sass = require "gulp-sass"


# CONFIG ##########################################################################################


paths =
  coffee: "source/**/*.coffee"
  scss: "source/**/*.scss"
  static: [
    "source/index.html"
    "source/fonts/*"
  ]


gulp_notify.logLevel(0)


# HELPER FUNCTIONS ################################################################################


del = (path)->
  if fs.existsSync path
    for file in fs.readdirSync path
      curPath = path + "/" + file
      if fs.lstatSync(curPath).isDirectory()
        del curPath
      else
        fs.unlinkSync curPath
      null
    fs.rmdirSync path


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


gulp.task "static", ()->
  gulp.src paths.static
    .pipe gulp.dest "dist"


gulp.task "scss", ()->
  gulp.src paths.scss
    .pipe gulp_natural_sort()
    .pipe gulp_concat "svga.scss"
    .pipe gulp_sass
      precision: 2
    .on "error", logAndKillError
    .pipe gulp.dest "dist"


# TASKS: SYSTEM ###################################################################################


gulp.task "del:dist", (cb)->
  del "dist"
  cb()


gulp.task "watch", (cb)->
  gulp.watch paths.coffee, gulp.series "coffee"
  gulp.watch paths.static, gulp.series "static"
  gulp.watch paths.scss, gulp.series "scss"
  cb()


gulp.task "compile",
  gulp.series "del:dist", "coffee", "static", "scss"


gulp.task "default",
  gulp.series "compile", "watch"

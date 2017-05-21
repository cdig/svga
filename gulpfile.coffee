chalk = require "chalk"
del = require "del"
gulp = require "gulp"
gulp_autoprefixer = require "gulp-autoprefixer"
gulp_coffee = require "gulp-coffee"
gulp_concat = require "gulp-concat"
gulp_natural_sort = require "gulp-natural-sort"
gulp_notify = require "gulp-notify"
gulp_rename = require "gulp-rename"
gulp_sass = require "gulp-sass"
gulp_uglify = require "gulp-uglify"
# gulp_using = require "gulp-using" # Uncomment and npm install for debug
path = require "path"
spawn = require("child_process").spawn


# STATE ##########################################################################################


prod = false


# CONFIG ##########################################################################################


paths =
  coffee: "source/**/*.coffee"
  html: "source/index.html"
  scss: "source/**/*.scss"


gulp_notify.logLevel(0)


# HELPER FUNCTIONS ################################################################################


logAndKillError = (err)->
  console.log chalk.bgRed("\n## Error ##")
  console.log chalk.red err.toString() + "\n"
  gulp_notify.onError(
    emitError: true
    icon: false
    message: err.message
    title: "👻"
    wait: true
    )(err)
  @emit "end"


cond = (predicate, action)->
  if predicate
    action()
  else
    # This is what we use as a noop *shrug*
    gulp_rename (p)-> p


# TASKS: COMPILATION #######################################################################  #####


gulp.task "coffee", ()->
  gulp.src paths.coffee
    .pipe gulp_natural_sort()
    .pipe gulp_concat "svga.coffee"
    .pipe gulp_coffee()
    .on "error", logAndKillError
    .pipe cond prod, gulp_uglify
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
    .pipe gulp_autoprefixer
      browsers: "last 5 Chrome versions, last 2 ff versions, IE >= 10, Safari >= 8, iOS >= 8"
      cascade: false
      remove: false
    .pipe gulp.dest "dist"


# TASKS: SYSTEM ###################################################################################


gulp.task "del:dist", ()->
  del "dist"


gulp.task "prod:setup", (cb)->
  prod = true
  cb()


gulp.task "watch", (cb)->
  gulp.watch paths.coffee, gulp.series "coffee"
  gulp.watch paths.html, gulp.series "html"
  gulp.watch paths.scss, gulp.series "scss"
  cb()


gulp.task "recompile",
  gulp.series "del:dist", "coffee", "html", "scss"


gulp.task "prod",
  gulp.series "prod:setup", "recompile"


gulp.task "default",
  gulp.series "recompile", "watch"

gulp = require "gulp"
gulp_autoprefixer = require "gulp-autoprefixer"
gulp_coffee = require "gulp-coffee"
gulp_concat = require "gulp-concat"
gulp_sass = require "gulp-sass"
gulp_uglify = require "gulp-uglify"


logAndKillError = (err)->
  console.log "\n## Error ##"
  console.log err.toString()
  @emit "end"

paths =
  coffee: "source/**/*.coffee"
  html: "source/wrapper/*.html"
  scss: [
    "pack/vars.scss"
    "source/**/*.scss"
  ]


gulp.task "coffee", ()->
  gulp.src paths.coffee
    .pipe gulp_concat "scripts.coffee"
    .pipe gulp_coffee()
    # .pipe gulp_uglify()
    .on "error", logAndKillError
    .pipe gulp.dest "dist"


gulp.task "html", ()->
  gulp.src paths.html
    .pipe gulp.dest "dist"


gulp.task "scss", ()->
  gulp.src paths.scss
    .pipe gulp_concat "styles.scss"
    .pipe gulp_sass
      errLogToConsole: true
      outputStyle: "compressed"
      precision: 1
    .on "error", logAndKillError
    .pipe gulp_autoprefixer
      browsers: "last 5 Chrome versions, last 2 ff versions, IE >= 10, Safari >= 8, iOS >= 8"
      cascade: false
      remove: false
    .pipe gulp.dest "dist"


gulp.task "watch", (cb)->
  gulp.watch paths.coffee, gulp.series "coffee"
  gulp.watch paths.html, gulp.series "html"
  gulp.watch paths.scss, gulp.series "scss"
  cb()


gulp.task "default", gulp.parallel "coffee", "html", "scss", "watch"

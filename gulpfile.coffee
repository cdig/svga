gulp = require "gulp"
gulp_autoprefixer = require "gulp-autoprefixer"
gulp_coffee = require "gulp-coffee"
gulp_concat = require "gulp-concat"
gulp_sass = require "gulp-sass"

gulp.task "coffee", ()->
  gulp.src "source/**/*.coffee"
    .pipe gulp_concat "scripts.coffee"
    .pipe gulp_coffee()
    .pipe gulp.dest "dist"

gulp.task "sass", ()->
  gulp.src "source/**/*.scss"
    .pipe gulp_concat "styles.scss"
    .pipe gulp_sass
      errLogToConsole: true
      outputStyle: "compressed"
      precision: 1
    .pipe gulp_autoprefixer
      browsers: "last 2 Chrome versions, last 2 ff versions, IE >= 10, Safari >= 9, iOS >= 9"
      cascade: false
      remove: false
    .pipe gulp.dest "dist"

gulp.task "default", ["coffee", "sass"]

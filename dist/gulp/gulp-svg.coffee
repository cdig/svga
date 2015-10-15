gulp = require 'gulp'
gutil = require 'gulp-util'
file = require 'gulp-file'
merge = require 'merge2'
concat = require 'gulp-concat'
require('coffee-script/register')
coffee = require('gulp-coffee')
parseArgs = require('minimist')(process.argv.slice(2));
gutil.log parseArgs



getActivityFinalise = (aName)->
  "Take ['crank', 'defaultElement', 'button','Joystick', 'SVGActivity', 'PageScrollWatcher'], (crank, defaultElement, button, Joystick, SVGActivity, PageScrollWatcher)->\n
  \t  activity.registerInstance('joystick', 'joystick')\n
  \t  activityName = '#{aName}'\n
  \t  activity.crank = crank\n
  \t  activity.button = button\n
  \t  activity.defaultElement = defaultElement\n
  \t  activity.joystick = Joystick\n
  \t  svgActivity = SVGActivity()\n
  \t  for pair in activity._instances\n
  \t    svgActivity.registerInstance(pair.name, activity[pair.instance])\n
  \t  svgActivity.registerInstance('default', activity.defaultElement)\n
  \t  page = PageScrollWatcher.getCurrentPage()\n

  \t  svg = page.querySelector('##{aName}-svg').contentDocument.querySelector('svg')\n

  \t  svgActivity.setupDocument(activityName, svg)"
gulp.task 'svgActivity', ['watch', 'svgActivityCompile']
gulp.task 'svgActivityCompile',->
  return merge(gulp.src(['bower_components/svg-activity/dist/setup/activity-begin.coffee',"bower_components/flow-arrows/dist/**/*.coffee", "source/activity/#{parseArgs.name}/**/*.coffee" ]), 
  file("activity-finalise.coffee", getActivityFinalise(parseArgs.name), { src: true }))
  .pipe(concat("#{parseArgs.name}-activity.coffee"))
  .pipe(coffee({}).on('error', gutil.log))
  .pipe(gulp.dest('./public'))

gulp.task 'watch', ->
  return gulp.watch(["source/activity/#{parseArgs.name}/*.coffee"], ['svgActivity'])
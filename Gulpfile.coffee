gulp = require 'gulp'
browserify = require 'browserify'
source = require 'vinyl-source-stream'

gulp.task 'default', ->
  browserify entries: ['./test/hkex.coffee']
    .transform 'coffeeify'
    .transform 'debowerify'
    .bundle()
    .pipe source 'hkex.js'
    .pipe gulp.dest './test'

// Generated by CoffeeScript 1.8.0
var autoprefixer, coffeeify, concat, gulp, minifycss, npmpackage, rename, replace, sourcemaps, stylus, uglify;

gulp = require('gulp');

rename = require('gulp-rename');

replace = require('gulp-replace');

concat = require('gulp-concat');

sourcemaps = require('gulp-sourcemaps');

npmpackage = require('./package.json');

gulp.task('watch', function() {
  gulp.watch(['components/*.styl'], ['style']);
  gulp.watch(['lib/*.css'], ['libstyle']);
  return gulp.watch(['components/*.coffee', 'lib/*.coffee', 'lib/*.js'], ['coffee']);
});

gulp.task('default', ['style', 'libstyle', 'coffee']);

stylus = require('gulp-stylus');

minifycss = require('gulp-minify-css');

autoprefixer = require('gulp-autoprefixer');

gulp.task('style', function() {
  return gulp.src('components/index.styl').pipe(sourcemaps.init()).pipe(stylus()).pipe(concat("" + npmpackage.name + "-" + npmpackage.version + ".min.css")).pipe(autoprefixer({
    browsers: ['last 2 versions']
  })).pipe(minifycss()).pipe(sourcemaps.write()).pipe(gulp.dest('dist'));
});

gulp.task('libstyle', function() {
  return gulp.src('lib/*.css').pipe(sourcemaps.init()).pipe(concat("" + npmpackage.name + "-" + npmpackage.version + ".lib.min.css")).pipe(autoprefixer({
    browsers: ['last 2 versions']
  })).pipe(minifycss()).pipe(sourcemaps.write()).pipe(gulp.dest('dist'));
});

uglify = require('gulp-uglify');

coffeeify = require('gulp-coffeeify');

gulp.task('coffee', function() {
  return gulp.src('./components/index.coffee').pipe(sourcemaps.init()).pipe(coffeeify()).pipe(uglify()).pipe(rename("" + npmpackage.name + "-" + npmpackage.version + ".min.js")).pipe(sourcemaps.write()).pipe(gulp.dest('dist'));
});

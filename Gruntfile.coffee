LIVERELOAD_PORT = 35729;
lrSnippet = require('connect-livereload')(port: LIVERELOAD_PORT)
mountFolder = (connect, dir) ->
    connect.static(require('path').resolve(dir))

###
The only requirement of Gruntfile is that it exports a function that accepts
the grunt object. In the body of this function, we will do the following:
  1. load our dependencies
  2. configure our plugins
  3. define our top-level tasks
###
module.exports = (grunt) ->
  # a simple way to load all the grunt plugins we have installed
  require('matchdep').filterDev('grunt-*').forEach grunt.loadNpmTasks

  options =
    app: 'app'
    temp: '.tmp'
    dist: 'dist'

  ###
  the main entry point for grunt: a massive object with configuration options
  for all of our grunt plugins.
  ###
  grunt.initConfig
    options: options

    # grunt-contrib-clean
    clean:
      dist:
        files: [
          '<%= options.temp %>'
          '<%= options.dist %>/*'
          '!<%= options.dist %>/.git*'
        ]
      server: '<%= options.temp %>'

    # grunt-contrib-coffee
    coffee:
      dist:
        files:
          expand: true
          cwd: '<%= options.app %>/scripts'
          src: '{,*/}*.coffee'
          dest: '<%= options.temp %>/styles'
          ext: '.js'
        options: {}

    # grunt-contrib-sass
    sass:
      dist:
        files:
          expand: true
          cwd: '<%= options.app %>/styles'
          src: '{,*/}*.{sass,scss}'
          dest: '<%= options.temp %>/styles'
          ext: '.css'

    # grunt-contrib-handlebars
    handlebars:
      dist:
        files:
          '<%= options.temp %>/templates.js': '<%= options.app %>/templates/{,*/}*.hbs'
        options:
          namespace: 'Templates'
          processName: (filePath) ->
            filename.match(/^<%= options.app %>\/templates\/(.+)\.h[bj]s$/)[1]

    # grunt-contrib-watch
    watch:
      coffee:
        files: ['<%= options.app %>/scripts/{,*/}.coffee']
        tasks: ['coffee:dist']
      styles:
        files: ['<%= options.app %>/styles/{,*/}.{sass,scss}']
        tasks: ['styles:dist']
      handlebars:
        files: ['<%= options.app %>/templates/{,*/}.hbs']
        tasks: ['handlebars:dist']
      livereload:
        options:
          livereload: LIVERELOAD_PORT
        files: [
          '<%= options.app %>/*.html'
          '{<%= options.temp %>,<%= yeoman.<%= options.app %> %>}/styles/{,*/}*.css',
          '{<%= options.temp %>,<%= yeoman.<%= options.app %> %>}/scripts/{,*/}*.js',
          '<%= yeoman.<%= options.app %> %>/images/{,*/}*.{png,jpg,jpeg,gif,webp,svg}'
        ]

    # grunt-contrib-connect
    # connect-livereload
    connect:
      options:
        port: 9000
        hostname: 'localhost'
      livereload:
        options:
          middleware: (connect) ->
            return [
              lrSnippet
              mountFolder connect, options.temp
              mountFolder connect, 'bower_components'
              mountFolder connect, options.app
            ]
      dist:
        options:
          middleware: (connect) ->
            return [mountFolder(connect, options.dist)]

    # grunt-contrib-open
    open:
      server:
        path: 'http://localhost:<%= connect.options.port %>'


    # <task>:
    #   <target>:
    #     files: [{
    #       expand: true
    #       cwd: 'src'
    #       src: '{,*/}*.coffee'
    #       dest: '<%= options.temp %>'
    #       ext: '.js'
    #     }, {'dist/test/spec.js': 'test/src/spec.coffee'}]
    #     options: {}
    # ...

  ###
  compose our top-level tasks from our individual plugins.
  grunt.registerTask 'name', 'description', ['task', 'task:target', ...]
  ###
  grunt.registerTask 'serve', 'compile and serve files for development', ['build', 'connect:livereload', 'open', 'watch']
  grunt.registerTask 'build', 'compile source files for production', ['coffee', 'sass', 'handlebars']
  grunt.registerTask 'test', 'run unit tests', []

  # what to do when you just run 'grunt' with no task name
  grunt.registerTask 'default', ['build', 'test']

# a little bit of setup for livereload and connect...
LIVERELOAD_PORT = 35729
lrSnippet = require('connect-livereload')(port: LIVERELOAD_PORT)
mountFolder = (connect, dir) ->
    connect.static(require('path').resolve(dir))

###
The only requirement of a Gruntfile is that it exports a function that accepts
the grunt object. In the body of this function, we will do the following:
  1. load our dependencies
  2. configure our plugins
  3. define our top-level tasks
###
module.exports = (grunt) ->
  # a simple way to load all the grunt plugins we have installed
  require('matchdep').filterDev('grunt-*').forEach grunt.loadNpmTasks

  # general config options for our project
  yeoman =
    # dev and build directories:
    app: 'app'
    temp: '.tmp'
    dist: 'dist'

  ###
  the main entry point for grunt: a massive object with configuration options
  for all of our grunt plugins.
  ###
  grunt.initConfig {
    # pass our config object to grunt so we can interpolate it into strings :)
    yeoman: yeoman

    # grunt-contrib-clean
    clean:
      dist: [
        '<%= yeoman.temp %>'
        '<%= yeoman.dist %>/*'
        '!<%= yeoman.dist %>/.git*'
      ]
      server: '<%= yeoman.temp %>'

    # grunt-contrib-coffee
    coffee:
      dist:
        files: [
          expand: true
          cwd: '<%= yeoman.app %>/scripts'
          src: '{,*/}*.coffee'
          dest: '<%= yeoman.temp %>/scripts'
          ext: '.js'
        ]

    # grunt-contrib-sass
    sass:
      dist:
        files: [
          expand: true
          cwd: '<%= yeoman.app %>/styles'
          src: '{,*/}*.{sass,scss}'
          dest: '<%= yeoman.temp %>/styles'
          ext: '.css'
        ]

    # grunt-contrib-handlebars
    handlebars:
      dist:
        files:
          '<%= yeoman.temp %>/scripts/templates.js': ['<%= yeoman.app %>/templates/{,*/}*.hbs']
        options:
          namespace: 'Templates'
          processName: (filename) ->
            filename.match(/templates\/(.+)\.h[bj]s$/)[1]

    # grunt-contrib-watch
    watch:
      coffee:
        files: ['<%= yeoman.app %>/scripts/{,*/}*.coffee']
        tasks: ['coffee:dist']
      styles:
        files: ['<%= yeoman.app %>/styles/{,*/}*.{sass,scss}']
        tasks: ['sass:dist']
      handlebars:
        files: ['<%= yeoman.app %>/templates/{,*/}*.hbs']
        tasks: ['handlebars:dist']
      livereload:
        options:
          livereload: LIVERELOAD_PORT
        files: [
          '<%= yeoman.app %>/*.html'
          '{<%= yeoman.temp %>,<%= yeoman.app %>}/styles/{,*/}*.css',
          '{<%= yeoman.temp %>,<%= yeoman.app %>}/scripts/{,*/}*.js',
          '<%= yeoman.app %>/images/{,*/}*.{png,jpg,jpeg,gif,webp,svg}'
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
              mountFolder connect, yeoman.temp
              mountFolder connect, yeoman.app
            ]
      dist:
        options:
          middleware: (connect) ->
            return [mountFolder(connect, yeoman.dist)]

    # grunt-open
    open:
      server:
        path: 'http://localhost:<%= connect.options.port %>'

    symlink:
      bower:
        src: 'bower_components'
        dest: '.tmp/bower_components'

    useminPrepare:
      html: '<%= yeoman.app %>/index.html'
      options:
        root: '<%= yeoman.temp %>'
        dest: '<%= yeoman.dist %>'

    usemin:
      options:
        dirs: ['<%= yeoman.dist %>']
      html: ['<%= yeoman.dist %>/{,*/}*.html'],
      # css: ['<%= yeoman.dist %>/styles/{,*/}*.css']

    copy:
      dist:
        files: [
          expand: true,
          cwd: '<%= yeoman.app %>'
          dest: '<%= yeoman.dist %>'
          src: [
            '*.html'
            '*.{ico,png,txt}'
            '.htaccess'
            'images/{,*/}*.{jpg,png,gif}' # TODO: imgmin
            'styles/fonts/*'
          ]
        ]

    # standard task definition looks like so:
    # <task>:
    #   <target>:
    #     files: [{
    #       'dist/test/spec.js': 'test/src/*.coffee' # short mode
    #     }, {
    #       expand: true  # long mode
    #       cwd: 'src'
    #       src: '{,*/}*.coffee'
    #       dest: '<%= yeoman.temp %>'
    #       ext: '.js'
    #     }]
    #     options: {}
  }

  grunt.registerTask 'compile', 'compile source files to temporary directory', [
    'clean'
    'coffee'
    'sass'
    'handlebars'
    'symlink'
  ]

  ###
  compose our top-level tasks from our individual plugins.
  grunt.registerTask 'name', 'description', ['task', 'task:target', ...]
  ###
  grunt.registerTask 'serve', 'compile and serve files for development', [
    'compile'
    'connect:livereload'
    'open'
    'watch'
  ]

  grunt.registerTask 'build', 'compile source files for production and launch prod server', [
    'compile'
    'copy'
    'useminPrepare'
    'concat'
    'uglify'
    'cssmin'
    'usemin'
    'open'
    'connect:dist:keepalive'
  ]

  grunt.registerTask 'test', 'run unit tests', [
  ]

  # what to do when you just run 'grunt' with no task name
  grunt.registerTask 'default', ['build', 'test']

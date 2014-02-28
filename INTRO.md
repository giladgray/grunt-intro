# British History 101
### Pastoral Web Development with Grunt and Bower

    Gilad Gray
    Friday, Feb 28, 2014
    Somewhere in England

# What is Grunt?
- A JavaScript task runner
- Built on NodeJS
- Simple, verbose syntax
- Tremendously flexible
- Huge developer community
- Over 2000 plugins
- Heavy use of `npm`

# A Simple Gruntfile
Suppose we've got a bunch of CoffeeScript in our `src/` directory and we'd like to compile it to one JavaScript file in the `dist/` directory.
```coffeescript
module.exports = (grunt) ->
  grunt.initConfig
    coffee:
      dist:
        files:
          'dist/main.js': 'src/*.coffee'
  grunt.registerTask 'default', ['coffee']
```

# A Closer Look
```coffeescript
# a Gruntfile must export a function that accepts the grunt object
# (this is classic CommonJS module syntax)
module.exports = (grunt) ->
  # initialize a configuration object for the current project
  grunt.initConfig
    # define a new task (corresponding to an installed plugin),
    # in this case it's grunt-contrib-coffee
    coffee:
      # and a target for that task
      dist:
        # every task requires a files option
        files:
          'dist/main.js': 'src/*.coffee'
        # and maybe some options
        options:
          join: true
          sourceMap: true
  # register a composite task using our plugin tasks.
  # 'default' is a special task that is run when you don't
  # provide a taskname to grunt
  grunt.registerTask 'default', ['coffee']
```

# It's Not All Roses
- Grunt requires a temp folder to dump files between steps
  - ex: `coffee` > .tmp *then* `requirejs` > dist
  - tasks don't talk to each other
  - need a place to store files in between
  - mitigate by making this your dev folder
- plugins often do more than one thing
  - `sass` compiles and minifies
  - documentation is crucial! (but also pretty standard)
  - gulp is the opposite extreme
- a complete Gruntfile will be *huuuuuuge*
  - configuration object syntax is verbose
  - easily hundreds of lines
  - use CoffeeScript for shorter syntax
  - can split across multiple files

# Workshop Time!
## Let's build a build system!
- a static client-side web app
- CoffeeScript, Sass, Handlebars
- Express-based static asset server
- LiveReload because we hate `Cmd+R`
- Concat, minify, and uglify our files for production
- Oh yeah, and run tests constantly!

# 0. Setup Phase...
1. `brew install node`
2. `npm install -g grunt-cli bower`
2. `npm install -g coffee-script`
3. `gem install sass`

# 1. New Project
1. `mkdir <project>`
1. `cd <project>`
2. `mkdir app`
3. create `app/index.html`
3. put some HTML in there, maybe a few gifs
3. let's view that file in Chrome

```html
<!-- app/index.html -->
<html>
    <head>
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
        <title>British History 101</title>
        <meta name="description" content="pastoral web development with Grunt and Bower">
        <meta name="viewport" content="width=device-width">
        <!-- Place favicon.ico and apple-touch-icon.png in the root directory -->
        <!-- build:css({.tmp,app}) styles/main.css -->
        <link rel="stylesheet" href="styles/main.css">
        <!-- endbuild -->
    </head>
    <body>
        <h1>Hello!</h1>
        <div id="main"></div>

        <!-- build:js scripts/main.js -->
        <script src="bower_components/handlebars/handlebars.runtime.js"></script>
        <script src="scripts/templates.js"></script>
        <script src="scripts/main.js"></script>
        <!-- endbuild -->
</body>
</html>
```

# 2. Grunt!
Let's add some styles to this bad boy.
1. `npm init`
2. `npm install --save-dev grunt matchdep`
2. `npm install --save-dev grunt-contrib-sass`
3. `mkdir app/styles`
3. create `app/styles/main.sass`
3. add ```<link rel="stylesheet" href="styles/main.css">``` to `<head>` of `index.html`
3. create `Gruntfile.coffee`:
  ```coffeescript
  # Gruntfile.coffee
  module.exports = (grunt) ->
    # a simple way to load all the grunt plugins we have installed
    require('matchdep').filterDev('grunt-*').forEach grunt.loadNpmTasks

    grunt.initConfig
      # grunt-contrib-sass
      sass:
        dist:
          files:
            'app/styles/main.css': 'app/styles/main.sass'
  ```
Try it: `grunt sass` and reload your `index.html` in Chrome

# 3. Grunt! Grunt!
Let's add CoffeeScript support.
1. `npm install --save-dev grunt-contrib-coffee`
2. `mkdir app/scripts`
3. create `app/scripts/main.coffee`
3. add the following task to your Grunfile:
    ```coffeescript
    # grunt-contrib-coffee
    coffee:
      dist:
        files: [
          expand: true
          cwd: 'app/scripts'
          src: '{,*/}*.coffee'
          dest: '.tmp/scripts'
          ext: '.js'
        ]
    ```
3. we've got enough now to make a compile task
    ```coffeescript
    grunt.registerTask 'compile',
      'compile source files to temporary directory',
      ['coffee', 'sass']
    ```

# 4. Let's Make a Server
1. `npm install --save-dev grunt-contrib-watch grunt-contrib-connect grunt-contrib-open connect-livereload`
1. define a `watch` task to recompile our files when they change
    ```coffeescript
    # grunt-contrib-watch
    watch:
      coffee:
        files: ['app/scripts/{,*/}*.coffee']
        tasks: ['coffee:dist']
      styles:
        files: ['app/styles/{,*/}*.{sass,scss}']
        tasks: ['sass:dist']
      handlebars:
        files: ['app/templates/{,*/}*.hbs']
        tasks: ['handlebars:dist']
      livereload:
        options:
          livereload: LIVERELOAD_PORT
        files: [
          'app/*.html'
          '{.tmp,app}/styles/{,*/}*.css',
          '{.tmp,app}/scripts/{,*/}*.js',
          'app/images/{,*/}*.{png,jpg,jpeg,gif,webp,svg}'
        ]
    ```
2. define a `connect` task that will launch a very simple [connect](http://www.senchalabs.org/connect/) server (middleware framework for Node.JS)
    ```coffeescript
    # grunt-contrib-connect
    # connect-livereload
    connect:
      options:
        port: 9000
        hostname: 'localhost'
      # development server with livereload
      livereload:
        options:
          middleware: (connect) ->
            return [
              lrSnippet
              mountFolder connect, '.tmp'
              mountFolder connect, 'app'
            ]
      # production server
      dist:
        options:
          middleware: (connect) ->
            return [mountFolder(connect, 'dist')]

    # grunt-open
    open:
      server:
        path: 'http://localhost:<%= connect.options.port %>'
    ```
3. make a `serve` task to run our development workflow
  ```coffeescript
    grunt.registerTask 'serve',
      'compile and serve files for development',
      [
        'compile'
        'connect:livereload'
        'open'
        'watch'
      ]
  ```

# 5. Ok, Templates
1. We've got coffee, sass, and a simple static server, what more do we need?
2. How about a template engine?
3. `npm install --save-dev grunt-contrib-handlebars grunt-contrib-symlink`
3. define the `handlebars` task
  ```coffeescript
  # Gruntfile.coffee
    # grunt-contrib-handlebars
    handlebars:
      dist:
        files:
          '.tmp/scripts/templates.js': ['app/templates/{,*/}*.hbs']
        options:
          namespace: 'Templates'
          processName: (filename) ->
            filename.match(/templates\/(.+)\.h[bj]s$/)[1]
 ```
3. create a template: `app/templates/item.hbs`

# Bower to the Rescue!
Great, we can compile our templates in Grunt. But in order to run them in the browser, we'll need the Handlebars `runtime`, which is a separate piece of code from the compiler.

**Bower** is Twitter's answer to `npm`. It's "the package manager for the web" and works exactly like the `npm` you know and love. The main difference is that bower's packages tend to be optimized for use in the browser. They'll often contain compiled code instead of full source and be in AMD format instead of CommonJS.

1. initialize bower
  ```bash
  $ bower init
  $ bower install --save handlebars
  $ bower list
  ```
3. install `handlebars.runtime` in your index.html
```
<!-- app/index.html -->
<script src="bower_components/handlebars/handlebars.runtime.js"></script>
```
3. but it won't work yet! because `bower_components/` is at the root level which isn't exposed in our server
3. quick symlink to the rescue! symlink `bower_components/` into our `.tmp/` folder so it'll be available to the client:
  ```coffeescript
  # Gruntfile.coffee
    # grunt-contrib-symlink
    symlink:
      bower:
        src: 'bower_components'
        dest: '.tmp/bower_components'
  ```
3. add `'handlebars'` and `'symlink'` to `compile` task list

# 5. Production!
Making your source ready for production doesn't have to be hard! Actually, if you've learned one thing here, I hope it's that JavaScript development itself doesn't have to be hard.

There's a pretty awesome plugin called `usemin` that will basically be our entire workflow. You may have noticed a block like this in `index.html`:
```html
<!-- build:js scripts/main.js -->
<script src="..."></script>
<!-- endbuild -->
```
`usemin` is going to parse our `index.html` and perform those build blocks, spitting out a new optimized `index.html` and `scripts/main.js` consisting of all files listed in the block **concatenated and uglified**. It'll also do the same thing for our CSS in a separate `build:css` block!

1. `npm install --save-dev grunt-usemin grunt-contrib-concat grunt-contrib-cssmin grunt-contrib-uglify grunt-contrib-copy`
2. define the `useminPrepare` and `usemin` tasks:
  ```coffeescript
  # Gruntfile.coffee
    # grunt-usemin
    # grunt-contrib-concat
    # grunt-contrib-cssmin
    # grunt-contrib-uglify
    useminPrepare:
      html: 'app/index.html'
      options:
        root: 'temp'
        dest: 'dist'

    usemin:
      options:
        dirs: ['dist']
      html: ['dist/{,*/}*.html']
  ```
3. the last step is to copy our static assets to the `dist/` folder as well
  ```coffeescript
  # Gruntfile.coffee
    # grunt-contrib-copy
    copy:
      dist:
        files: [
          expand: true,
          cwd: 'app'
          dest: 'dist'
          src: [
            '*.{html,ico,png,txt}'
            '.htaccess'
            'images/{,*/}*.{jpg,png,gif}'
            'styles/fonts/*'
          ]
        ]
  ```
3. `usemin` will define the configurations for `concat`, `uglify`, and `cssmin` tasks based on the `build` blocks in our `index.html`
4. last step: let's write the `build` task:
  ```coffeescript
  # Gruntfile.coffee
    grunt.registerTask 'build',
      'compile source files for production and launch prod server',
      [
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
  ```

# Other Things
- Web scaffolding: [Yeoman](http://yeoman.io)
  - [Fantastic tutorial](http://yeoman.io/codelab.html)
- Other build tools:
  - [Gulp](http://gulpjs.com/)
  - [Brunch](http://brunch.io/)
- Interesting articles:
  - [Grunt for People Who Think Things Like Grunt are Weird and Hard](http://24ways.org/2013/grunt-is-not-weird-and-hard/)
  - [Gulp, Grunt, Whatever](http://blog.ponyfoo.com/2014/01/09/gulp-grunt-whatever)

# &nbsp;

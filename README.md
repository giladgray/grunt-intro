# British History 101
### Pastoral web development with Grunt and Bower

## Usage
* `brew install node`
* `npm install -g grunt-cli bower`
* `git clone` this repo, `cd grunt-intro`
* `npm install && bower install`
* `grunt serve`

Or just view [INTRO.md](INTRO.md) on GitHub and follow along :)

## Education
**Steps to get started:**

1. `git init`, `npm init`, `bower init`
1. define app structure
1. write `Gruntfile.coffee`
  * make a task for each technology you'll use
  * combine them into reasonable abstract tasks
  * define a default task
1. write some code

### My App Structure
Look at how this project is architected. Source files live in the `app/` directory and are structured vertically, grouped by type. This makes for very simple task definitions: I can glob all coffee files with `app/scripts/**/*.coffee`. (Although, to be fair, I could glob them pretty easily like that no matter where they are.) 
```
project/
├─┬ app/
│ ├─┬ images/
│ │ └── *.{jpg,png,gif}
│ ├─┬ scripts/
│ │ └── *.coffee
│ ├─┬ styles/
│ │ └── *.{sass,scss}
│ ├─┬ templates/
│ │ └── *.hbs
│ └── index.html
├─┬ test/
│ └── *-spec.coffee
├─┬ [.tmp/]
│ └── development files
├─┬ [dist/]
│ └── production files
├── [node_modules/]
├── [bower_components/]
├── .editorconfig
├── .gitignore
├── bower.json
├── package.json
├── Gruntfile.coffee
└── README.md
[folders in brackets are excluded from source control]
```
I find that for a small app developed by a handful of people at most, this structure tends to work wonders. Files are easy to locate and any one folder rarely grows too large. I'll tend to introduce subfolders to my `scripts/` directory, such as `models/` and `views/` if I'm building a Backbone app. It can also help to split `templates/` into layouts, partials, and view templates. I find that `styles/` rarely grows large enough to warrant subfolders: a CSS framework does most of the heavy lifting there.

If you choose instead to organize horizontally (by feature, instead of file type), I'd suggest just plopping the CSS, JS, and Handlebars files directly into the feature folder instead of polluting your project with endless `feature*/scripts/` folders.

## Workflow
1. new project
3. app structure
4. index.html
5. put some gifs in there
6. open in chrome
7. intro grunt
8. npm init
5. coffee task
6. sass task
7. watch task
8. connect task
7. livereload task
7. handlebars task
  1. intro bower
  2. bower init
  2. bower install handlebars
  2. build:js entries for runtime and templates.js
  3. render template
4. usemin task
  5. + concat, uglify, cssmin + symlink + copy
6. imgmin task?
7. Grunt plugin directory
8. yo???

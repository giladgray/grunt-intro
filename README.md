# British History 101
### Pastoral web development with Grunt and Bower

## Usage
* `git clone`
* `npm install && bower install`
* `grunt serve`

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
├─┬ .tmp/
│ └── development files
├─┬ dist/
│ └── production files
├── node_modules/
├── bower_components/
├── .editorconfig
├── .gitignore
├── bower.json
├── package.json
├── Gruntfile.coffee
└── README.md
```
I find that for a small app developed by a handful of people at most, this structure tends to work wonders. Files are easy to locate and any one folder rarely grows too large. I'll tend to introduce subfolders to my `scripts/` directory, such as `models/` and `views/` if I'm building a Backbone app. It can also help to split `templates/` into layouts, partials, and view templates. I find that `styles/` rarely grows large enough to warrant subfolders: a CSS framework does most of the heavy lifting there.

If you choose instead to organize horizontally (by feature, instead of file type), I'd suggest just plopping the CSS, JS, and Handlebars files directly into the feature folder instead of polluting your project with endless `feature*/scripts/` folders.

require! {
  \./init.ls : { src, build, bin }
  \./process.ls : { get-src, each-src }
  shelljs : { exec }
}

compile-pug = (file) !->
  exec "#{bin.pug} #{file}", (err, out) !->
    if err
      throw err
    else
      html-file = file.replace /.pug$/, '.html'
      exec "cp #{html-file} #{build.firefox.html}"
      exec "mv #{html-file} #{build.chrome.html}"

compile-stylus = (file) !->
  exec "#{bin.stylus} #{file}", (err, out) !->
    if err
      throw err
    else
      css-file = file.replace /.styl$/, '.css'
      exec "cp #{css-file} #{build.firefox.css}"
      exec "mv #{css-file} #{build.chrome.css}"

build-common = !->
  exec "cp -rf #{src.firefox.manifest} #{build.firefox.manifest}"
  exec "cp -rf #{src.chrome.manifest} #{build.chrome.manifest}"
  exec "cp -rf #{src.images} #{build.chrome.images}"
  exec "cp -rf #{src.images} #{build.firefox.images}"
  exec "cp -rf #{src.third-js} #{build.chrome.js}"
  exec "cp -rf #{src.third-js} #{build.firefox.js}"
  each-src (file) !->
    compile-pug file
  , get-src, "pug"
  each-src (file) !->
    compile-stylus file
  , get-src, "stylus"


compile-ls = (file, build-path) !->
  exec "#{bin.lsc} #{file}", (err, out) !->
    if err
      throw err
    else
      js-file = file.replace /.ls$/, '.js'
      exec "mv #{js-file} #{build-path}"

build-firefox = !->
  each-src (file) !->
    compile-ls file, build.firefox.js
  , get-src, "lsFf"

build-chrome = !->
  each-src (file) !->
      compile-ls file, build.chrome.js
  , get-src, "lsChr"

flags = process.argv
  .filter (x) -> x.match /^-.+/
    .map (x) -> x.replace '-' ''

build-common!
if flags.includes 'firefox'
  build-firefox!
else if flags.includes 'chrome'
  build-chrome!
else
  build-firefox!
  build-chrome!

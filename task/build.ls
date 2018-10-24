require! {
  \./init.ls : { src, build, bin }
  \./process.ls : { get-src, each-src }
  shelljs : { exec }
}

build-firefox = !->
  each-src (file) !->
    exec "#{bin.lsc} #{file}"
    exec "mv #{file.replace /.ls$/, '.js'} #{build.firefox.js}"
  , get-src, "lsFf"

build-chrome = !->
  each-src (file) !->
    exec "#{bin.lsc} #{file}"
    exec "mv #{file.replace /.ls$/, '.js'} #{build.chrome.js}"
  , get-src, "lsChr"

flags = process.argv
  .filter (x) -> x.match /^-.+/
    .map (x) -> x.replace '-' ''

if flags.includes 'firefox'
  build-firefox!
else if flags.includes 'chrome'
  build-chrome!
else
  build-firefox!
  build-chrome!

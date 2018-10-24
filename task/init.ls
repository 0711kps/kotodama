require! {
  path
}

src =
  firefox:
    manifest: path.join "src", "firefox", "manifest.json"
    ls: path.join "src", "firefox", "ls" 
  chrome:
    manifest: path.join "src", "chrome", "manifest.json"
    ls: path.join "src", "chrome", "ls"
  pug: path.join "src", "pug"
  stylus: path.join "src", "stylus"
build =
  firefox:
    css: path.join "build", "firefox", "css"
    html: path.join "build", "firefox", "html"
    js: path.join "build", "firefox", "js"
  chrome:
    css: path.join "build", "chrome", "css"
    html: path.join "build", "chrome", "html"
    js: path.join "build", "chrome", "js"
bin =
  lsc: path.join "node_modules", ".bin", "lsc -c"
  pug: path.join "node_modules", ".bin", "pug"

export src, build, bin

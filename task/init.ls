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
  images: path.join "src", "images"
  third-js: path.join "src", "third-js"
build =
  firefox:
    css: "css"
    html: "html"
    js: "js"
    images: "images"
    manifest: "manifest.json"
  chrome:
    css: "css"
    html: "html"
    js: "js"
    images: "images"
    manifest: "manifest.json"
for key1, obj of build
  for key2, val of obj
    obj[key2] = path.join "build", key1, val
  
bin =
  lsc: "lsc -c -b"
  pug: "pug"
  stylus: "stylus"
for key, val of bin
  bin[key] = path.join "node_modules", ".bin", val

export src, build, bin

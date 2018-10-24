require! {
  fs
  \./init.ls : { src }
  path
}

get-files-template = (dir-path) ->>
  await new Promise (resolve, reject) !->
    fs.readdir dir-path, (err, files) !->
      resolve files.map (file) -> path.join dir-path, file

get-src =
  ls-ff: ->
    get-files-template src.firefox.ls

  ls-chr: ->
    get-files-template src.chrome.ls

  pug: ->
    get-files-template src.pug

  stylus: ->
    get-files-template src.stylus

each-src = (task, get-src, src-type) !->
  get-src[src-type]!.then (files) !->
    for file in files
      task file


export get-src, each-src

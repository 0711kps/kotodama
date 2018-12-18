const { copyFile, writeFile, readFile, readdir } = require('fs')
const { extname, basename } = require('path')
const { pathSplit, compileLS, minifyJS, compilePug, compileStylus, minifyCS, minifyJSON } = require('./k-lib.js')
const browsers = ['firefox', 'chrome']

browsers.forEach(browser => {
  readFile(`src/${browser}/manifest.json`, { encoding: 'utf-8' }, (err, data) => {
    let jsonContent = minifyJSON(data)
    writeFile(`build/${browser}/manifest.json`, jsonContent, err => {
      if(err) throw err
      console.log(`${browser} manifest file copied`)
    })
  })
  readdir(`src/${browser}/ls`, (err, lsFiles) => {
    lsFiles.forEach(ls => {
      let lsPath = `src/${browser}/ls/${ls}`
      let outputPath = `build/${browser}/js/${ls.replace('.ls', '.js')}`
      readFile(lsPath, { encoding: 'utf-8'}, (err, data) => {
        let lsContent = minifyJS(compileLS(data, { bare: true, header: false })).code
        writeFile(outputPath, lsContent, err => {
          if(err) throw err
          console.log(`livescript ${browser} ${ls} compiled!`)
        })
      })
    })
  })
})

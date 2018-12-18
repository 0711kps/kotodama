const { copyFile, writeFile, readFile, readFileSync, readdir, readdirSync } = require('fs')
const { extname, basename } = require('path')
const { compileLS, minifyJS, compilePug, compileStylus, minifyCSS, minifyJSON } = require('./k-lib.js')
const browsers = ['firefox', 'chrome']

let images = readdirSync('src/images').map(img => {
  return { source: `src/images/${img}`, filename: img }
})
let htmls = readdirSync('src/pug').map(pug => {
  return { filename: pug.replace('.pug', '.html'), content: compilePug(`src/pug/${pug}`) }
})
let csses = readdirSync('src/stylus').map(styl => {
  let stylContent = readFileSync(`src/stylus/${styl}`,{ encoding: 'utf-8' })
  return { filename: styl.replace('.styl', '.css'), content: minifyCSS(compileStylus(stylContent)).css }
})

browsers.forEach(browser => {
  readFile(`src/${browser}/manifest.json`, { encoding: 'utf-8' }, (err, data) => {
    let jsonContent = minifyJSON(data)
    writeFile(`build/${browser}/manifest.json`, jsonContent, err => {
      if(err) throw err
      console.log(`${browser} manifest file copied`)
    })
  })
  images.forEach(img => {
    copyFile(img.source, `build/${browser}/images/${img.filename}`, err => {
      if(err) throw err
    })
  })
  console.log('images copied!')
  htmls.forEach(html => {
    writeFile(`build/${browser}/html/${html.filename}`, html.content, err => {
      if(err) throw err
    })
  })
  console.log('html compiled!')
  csses.forEach(css => {
    writeFile(`build/${browser}/css/${css.filename}`, css.content, err => {
      if(err) throw err
    })
  })
  console.log('css compiled!')
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

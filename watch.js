const { watch, copyFile, writeFile, readFile } = require('fs')
const { join, extname, basename } = require('path')
const compileLS = require('livescript').compile
const minifyJS = require('terser').minify
const compilePug = require('pug').renderFile
const compileStylus = require('stylus').render
const minifyCSS = require('csso').minify


const browserCheck = filePath => {
  if(filePath.includes('firefox')) {
    return 'build/firefox/'
  }else{
    return 'build/chrome/'
  }
}

const pathSplit = filePath => {
  let ext = extname(filePath)
  let name = basename(filePath).replace(ext, '')
  let unixPath = `src/${filePath.replace(/\\/g, '/')}`
  return {ext: ext, name: name, unixPath: unixPath}
}

const handleManifest = filePath => {
  let { ext, name, unixPath } = pathSplit(filePath)
  let outputPath = `${browserCheck(filePath)}${name}${ext}`
  copyFile(unixPath, outputPath, err => {
    if(err) throw err
    console.log('manifest file copied!')
  })
}

const handleLivescript = filePath => {
  let { name, unixPath } = pathSplit(filePath)
  let outputPath = `${browserCheck(filePath)}js/${name}.js`
  readFile(unixPath, { encoding: 'utf-8' }, (err, data) => {
    if(err) throw err
    let lsContent = compileLS(data, { bare: true, header: false })
    let lsContentMini = minifyJS(lsContent).code
    writeFile(outputPath, lsContentMini, err => {
      if(err) throw err
      console.log('livescript compiled!')
    })
  })
}

const dualPath = subDir => {
  return ['firefox', 'chrome'].map(browser => {
    return `build/${browser}/${subDir}/`
  })
}

const handlePug = filePath => {
  let { name, unixPath } = pathSplit(filePath)
  let pugContent = compilePug(unixPath)
  dualPath('html').forEach(outputPath => {
    writeFile(`${outputPath}${name}.html`, pugContent, err => {
      if(err) throw err
    })
  })
  console.log('pug compiled!')
}

const handleStylus = filePath => {
  let { name, unixPath } = pathSplit(filePath)
  readFile(unixPath, { encoding: 'utf-8'}, (err, data) => {
    if(err) throw err
    let cssContent = compileStylus(data)
    let cssContentMini = minifyCSS(cssContent).css
    dualPath('css').forEach(outputPath => {
      writeFile(`${outputPath}${name}.css`, cssContentMini, err => {
        if(err) throw err
      })
    })
    console.log('css compiled!')
  })
}

watch('src', { recursive: true }, (event, filePath) => {
  let ext = extname(filePath)
  let name = basename(filePath).replace(ext, '')
  if(!filePath.includes('#') && ext) {
    if(typeof handleFile !== 'undefined') clearTimeout(handleFile)
    handleFile = setTimeout(() => {
      if(filePath.includes('manifest.json')) {
        handleManifest(filePath)
      }else if(filePath.includes('ls')) {
        handleLivescript(filePath)
      }else if(filePath.includes('pug')) {
        handlePug(filePath)
      }else if(filePath.includes('stylus')) {
        handleStylus(filePath)
      }
    },200)
  }
})

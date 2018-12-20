const { watch, copyFile, writeFile, readFile } = require('fs')
const { extname, basename } = require('path')
const { pathSplit,
        compileLS,
        minifyJS,
        compilePug,
        compileStylus,
        minifyCSS,
        minifyJSON} = require('./k-lib.js')


const browserCheck = filePath => {
  if(filePath.includes('firefox')) {
    return 'build/firefox/'
  }else{
    return 'build/chrome/'
  }
}

const handleManifest = filePath => {
  let { unixPath } = pathSplit(filePath)
  let outputPath = `${browserCheck(filePath)}manifest.json`
  let inputPath = 'src/' + filePath
  readFile(inputPath, { encoding: 'utf-8'}, (err, data) => {
    if(err) throw err
    let jsonContent = minifyJSON(data)
    writeFile(outputPath, jsonContent, err => {
      if(err) throw err
      console.log('manifest file copied!')
    })
  })
}

const handleLocaleMessages = filePath => {
  let { unixPath } = pathSplit(filePath)
  readFile(unixPath, { encoding: 'utf-8' }, (err, data) => {
    if(err) throw err
    let localeMessageContent = minifyJSON(data)
    let browsers = ['chrome', 'firefox']
    browsers.forEach(browser => {
      let localeFilename = unixPath.replace('src/', '')
      writeFile(`build/${browser}/${localeFilename}`, localeMessageContent, err => {
        if(err) throw err
      })
    })
  })
  console.log('locales file copied!')
}

const handleLivescript = filePath => {
  let { name, unixPath } = pathSplit(filePath)
  let outputPath = `${browserCheck(filePath)}js/${name}.js`
  readFile(unixPath, { encoding: 'utf-8' }, (err, data) => {
    if(err) throw err
    let lsContent = minifyJS(compileLS(data, { bare: true, header: false })).code
    writeFile(outputPath, lsContent, err => {
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
    let cssContent = minifyCSS(compileStylus(data)).css
    dualPath('css').forEach(outputPath => {
      writeFile(`${outputPath}${name}.css`, cssContent, err => {
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
      }else if(filePath.includes('messages.json')) {
        handleLocaleMessages(filePath)
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

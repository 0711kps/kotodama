const { extname, basename } = require('path')
const compileLS = require('livescript').compile
const minifyJS = require('terser').minify
const compilePug = require('pug').renderFile
const compileStylus = require('stylus').render
const minifyCSS = require('csso').minify
const minifyJSON = require('jsonminify')
const sayErr = filePath => err => { if (err) throw (`error with ${filePath}`) }
const mkdirIf = dirPath => { if (!existsSync(dirPath)) mkdirSync(dirPath) }
const shareRoot = 'src/share'
const { copyFile, writeFile, readFileSync, readdirSync, existsSync, mkdirSync } = require('fs')

const pathSplit = filePath => {
  let ext = extname(filePath)
  let name = basename(filePath).replace(ext, '')
  let unixPath = `src/${filePath.replace(/\\/g, '/')}`
  return { ext: ext, name: name, unixPath: unixPath }
}

const handlers = {
  images: imagePath => {
    let fileName = basename(imagePath)
    let targetDir = 'build/images'
    mkdirIf(targetDir)
    copyFile(imagePath, `${targetDir}/${fileName}`, sayErr(imagePath))
  },
  livescripts: lsPath => {
    let scriptName = basename(lsPath).replace('.ls', '.js')
    let targetDir = 'build/javascripts'
    mkdirIf(targetDir)
    let scriptContent = minifyJS(compileLS(readFileSync(lsPath, { encoding: 'UTF-8' }), { bare: true, header: false })).code
    writeFile(`${targetDir}/${scriptName}`, scriptContent, sayErr(lsPath))
  },
  _locales: messagesPath => {
    let locale = messagesPath.split('/')[3]
    let localeContent = minifyJSON(readFileSync(messagesPath, { encoding: 'UTF-8' }))
    let targetDir1 = 'build/_locales'
    let targetDir2 = `build/_locales/${locale}`
    mkdirIf(targetDir1)
    mkdirIf(targetDir2)
    writeFile(`${targetDir2}/messages.json`, localeContent, sayErr(messagesPath))
  },
  manifest: manifestPath => {
    let targetDir = 'build'
    let manifestContent = minifyJSON(readFileSync(manifestPath, { encoding: 'UTF-8' }))
    mkdirIf(targetDir)
    writeFile(`${targetDir}/manifest.json`, manifestContent, sayErr(manifestPath))
  },
  pugs: pugPath => {
    let fileName = basename(pugPath).replace('.pug', '.html')
    let htmlContent = compilePug(pugPath)
    let targetDir = 'build/htmls'
    mkdirIf(targetDir)
    writeFile(`${targetDir}/${fileName}`, htmlContent, sayErr(pugPath))
  },
  styluses: stylPath => {
    let fileName = basename(stylPath).replace('.styl', '.css')
    let cssContent = minifyCSS(
      compileStylus(
        readFileSync(stylPath, { encoding: 'UTF-8' })
      )
    ).css
    let targetDir = 'build/csses'
    mkdirIf(targetDir)
    writeFile(`${targetDir}/${fileName}`, cssContent, sayErr(stylPath))
  },
  thirdjs: jsPath => {
    let fileName = basename(jsPath)
    let targetDir = 'build/thirdjs'
    mkdirIf(targetDir)
    copyFile(jsPath, `${targetDir}/${fileName}`, sayErr(jsPath))
  }
}

const handleShare = () => {
  console.log('building common part of extension...')
  readdirSync(shareRoot).forEach(dir => {
    readdirSync(`${shareRoot}/${dir}`).forEach(target => {
      if (handlers[dir]) handlers[dir](`${shareRoot}/${dir}/${target}`)
    })
  })
  console.log('common part built')
}

const handleBrowser = (browser) => {
  console.log(`building extension for ${browser}...`)
  let browserRoot = `src/${browser}`
  readdirSync(browserRoot).forEach(dir => {
    readdirSync(`${browserRoot}/${dir}`).forEach(target => {
      if (handlers[dir]) handlers[dir](`${browserRoot}/${dir}/${target}`)
    })
  })
  console.log(`${browser} part built`)
}

module.exports = { pathSplit, compileLS, minifyJS, compilePug, compileStylus, minifyCSS, minifyJSON, handlers, handleShare, handleBrowser }

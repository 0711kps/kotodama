const { extname, basename } = require('path')
const compileLS = require('livescript').compile
const minifyJS = require('terser').minify
const compilePug = require('pug').renderFile
const compileStylus = require('stylus').render
const minifyCSS = require('csso').minify
const minifyJSON = require('jsonminify')

const pathSplit = filePath => {
  let ext = extname(filePath)
  let name = basename(filePath).replace(ext, '')
  let unixPath = `src/${filePath.replace(/\\/g, '/')}`
  return {ext: ext, name: name, unixPath: unixPath}
}


module.exports =  { pathSplit, compileLS, minifyJS, compilePug, compileStylus, minifyCSS, minifyJSON }

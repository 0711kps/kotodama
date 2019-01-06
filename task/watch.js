const { watch } = require('fs')
const { dirname, extname } = require('path')
const { handlers } = require('./k-lib.js')

watch('src', { recursive: true }, (event, filePath) => {
  let ext = extname(filePath)
  if(!filePath.includes('#') && ext) {
    if(typeof preventDuplicateEvent !== 'undefined') clearTimeout(preventDuplicateEvent)
    preventDuplicateEvent = setTimeout(() => {
      formatedFilePath = `src/${filePath.replace(/\\/g, '/')}`
      let lastFolder = dirname(formatedFilePath).split('/').reverse()[0]
      handlers[lastFolder](formatedFilePath)
      console.log(`the change spotted: ${formatedFilePath}`)
    }, 200)
  }
})

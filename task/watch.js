const { watch } = require('fs')
const { extname } = require('path')
const { handlers } = require('./k-lib.js')

watch('src', { recursive: true }, (event, filePath) => {
  let ext = extname(filePath)
  let preventDuplicateEvent = null
  if (!filePath.includes('#') && ext) {
    if (typeof preventDuplicateEvent !== 'undefined') clearTimeout(preventDuplicateEvent)
    preventDuplicateEvent = setTimeout(() => {
      let formatedFilePath = `src/${filePath.replace(/\\/g, '/')}`
      let handlerName = formatedFilePath.split('/')[2]
      handlers[handlerName](formatedFilePath)
      console.log(`the change spotted: ${formatedFilePath}`)
    }, 200)
  }
})

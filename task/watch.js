const chokidar = require('chokidar')
const { extname } = require('path')
const { handlers } = require('./k-lib.js')

chokidar.watch('src').on('change', (filePath, event) => {
  let ext = extname(filePath)
  let preventDuplicateEvent = null
  if (!filePath.includes('#') && ext) {
    if (typeof preventDuplicateEvent !== 'undefined') clearTimeout(preventDuplicateEvent)
    preventDuplicateEvent = setTimeout(() => {
      let formatedFilePath = filePath.replace(/\\/g, '/')
      let handlerName = formatedFilePath.split('/')[2]
      handlers[handlerName](formatedFilePath)
      console.log(`the change spotted and handled: ${formatedFilePath}`)
    }, 200)
  }
})

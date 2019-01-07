const { handleShare, handleBrowser } = require('./k-lib.js')

switch(process.argv[2]) {
case 'firefox':
  handleBrowser('firefox')
  break
case 'chrome':
  handleBrowser('chrome')
  break
default:
  console.log('????????')
}

handleShare()

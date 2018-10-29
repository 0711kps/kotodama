firebase.initializeApp(config)

send-kotodama = (req, sender, send-res) !->
  url-hash = md5 req.url
  console.log url-hash
  firebase.database!.ref(url-hash).push req.msg
  send-res true

browser.runtime.on-message.add-listener send-kotodama

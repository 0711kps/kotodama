firebase.initializeApp(config!)

send-kotodama = (req, sender, send-res) !->
  url-hash = md5 req.url
  firebase.database!.ref(url-hash).push req.msg
  send-res true

chrome.runtime.on-message.add-listener send-kotodama

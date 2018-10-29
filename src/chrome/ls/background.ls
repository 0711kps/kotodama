firebase.initializeApp(config!)

send-kotodama = (req, sender, send-res) !->
  firebase.database!.ref(req.url).push req.msg
  send-res true

chrome.runtime.on-message.add-listener send-kotodama

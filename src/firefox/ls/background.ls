firebase.initializeApp(config)

send-kotodama = (req, sender, send-res) !->
  url-hash = md5 req.url
  firebase.database!.ref(url-hash).push req.msg, (error) !->
    if error
      console.log "something wrong happened!"
    else
      get-kotodama req.url, req.tab-id
  send-res true
get-kotodama = (url, tab-id) !->
  url-hash = md5 url.replace /https?|:|\.|\/|www|#|&/g, ''
  firebase.database!.ref(url-hash).once('value').then (snapshot) !->
    msgs = snapshot.val!
    msgs-amount = "0"
    if msgs
      msgs-arr = Object.values msgs
      msgs-amount = msgs-arr.length.to-string!
    browser.browser-action.set-badge-text text: msgs-amount, tab-id: tab-id

browser.runtime.on-message.add-listener send-kotodama
browser.tabs.on-updated.add-listener (tab-id, change-info, tab) !->
  if change-info.status == "loading"
    url = tab.url
    get-kotodama(url, tab-id)

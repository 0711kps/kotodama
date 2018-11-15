firebase.initializeApp(config!)

send-kotodama = (req, sender, send-res) !->
  url-hash = md5 req.url
  console.log req.url
  console.log url-hash
  firebase.database!.ref(url-hash).push req.msg, (error) !->
    if error
      console.log "something wrong happened!"
    else
      get-kotodama req.url, req.tab-id
  send-res true
get-kotodama = (url, tab-id) !->
  url-hash = md5 url.replace(/https?:\/\/|\.|\/|www|#/g,'')
  firebase.database!.ref(url-hash).once('value').then (snapshot) !->
    msgs = snapshot.val!
    msgs-arr = []
    msgs-amount = "0"
    if msgs
      msgs-arr = Object.values msgs
      msgs-amount = msgs-arr.length.to-string!
    chrome.browser-action.set-badge-text text: msgs-amount, tab-id: tab-id
    tabs-info = {}
    tab-obj = msgs: msgs-arr, display: false
    tabs-info[tab-id] = tab-obj
    chrome.storage.local.set tabs-info

remove-local-kotodama = (tab-id) !->
  chrome.storage.local.remove tab-id.to-string!

chrome.runtime.on-message.add-listener send-kotodama
chrome.tabs.on-updated.add-listener (tab-id, change-info, tab) !->
  if change-info.status == "loading"
    url = tab.url
    if url.match /^https?:\/\/\w+(\.\w+){1,4}\//
      get-kotodama(url, tab-id)
chrome.tabs.on-removed.add-listener remove-local-kotodama

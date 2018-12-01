firebase.initializeApp(config)

handle-kotodama-badge = (amount, tab-id) !->
  badge-str = amount.to-string!
  if amount < 10
    badge-color = 'hsla(220, 100%, 40%, 0.4)'
  else if amount < 100
    badge-color = 'hsla(120, 100%, 40%, 0.4)'
  else if amount < 1000
    badge-color = 'hsla(50, 100%, 40%, 0.4)'
  else
    badge-color = 'hsla(0, 100%, 40%, 0.4)'
    if amount < 1000000
      badge-str = Math.floor amount / 1000 .to-string! + \k
    else
      badge-str = \xxx
  browser.browser-action.set-badge-text text: badge-str, tab-id: tab-id
  browser.browser-action.set-badge-background-color color: badge-color, tab-id: tab-id

handle-message = (req, sender, send-res) !->
  if req.type == 1
    send-kotodama req, send-res

send-kotodama = (req, send-res) !->
  url-hash = md5 req.url
  firebase.database!.ref(url-hash).push req.msg, (error) !->
    if error
      console.log "something wrong happened!"
    else
      get-kotodama req.url, req.tab-id
  send-res true

get-kotodama = (url, tab-id) !->
  url-hash = md5 url.replace /(https?:|[./#&?+=]|www)/g, ''
  firebase.database!.ref(url-hash).once \value .then (snapshot) !->
    msgs = snapshot.val!
    msgs-arr = []
    msgs-amount = 0
    if msgs
      msgs-arr = Object.values msgs
      msgs-amount = msgs-arr.length
    handle-kotodama-badge msgs-amount, tab-id
    tab-info = {}
    tab-obj = msgs: msgs-arr, display: false
    tab-info[tab-id] = tab-obj
    browser.storage.local.set tab-info

remove-local-kotodama = (tab-id) !->
  browser.storage.local.remove tab-id.to-string!

browser.runtime.on-message.add-listener handle-message
browser.tabs.on-updated.add-listener (tab-id, change-info, tab) !->
  if change-info.status == \loading
    url = tab.url
    if url.match /^https?:\/\/(\w|-)+(\.\w+){1,4}\//
      get-kotodama(url, tab-id)
browser.tabs.on-removed.add-listener remove-local-kotodama

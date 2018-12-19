firebase.initializeApp(config)

initialize-extension = ! ->
  chrome.storage.local.clear
  extension-options = ng-list: false, colorful-kotodama: true
  chrome.storage.local.set extension-options
  chrome.notifications.create({message: chrome.i18n.get-message('greeting'), title: chrome.i18n.get-message('extName'), type: 'basic', iconUrl: chrome.extension.getURL("images/logo-48.png")})

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
  chrome.browser-action.set-badge-text text: badge-str, tab-id: tab-id
  chrome.browser-action.set-badge-background-color color: badge-color, tab-id: tab-id

handle-message = (req, sender, send-res) !->
  if req.type == 1
    send-kotodama req, send-res
  else if req.type == 2
    tab-id = sender.tab.id
    chrome.storage.local.get tab-id.to-string! , (obj) !->
      chrome.tabs.send-message tab-id, obj[tab-id.to-string!].msgs

send-kotodama = (req, send-res) !->
  url-hash = md5 req.url
  firebase.database!.ref(url-hash).push req.msg, (err) !->
    if err
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
    tabs-info = {}
    tab-obj = msgs: msgs-arr, display: false
    tabs-info[tab-id] = tab-obj
    chrome.storage.local.set tabs-info

remove-tab-cache = (tab-id) !->
  chrome.storage.local.remove tab-id.to-string!

remove-window-cache = (window-id) !->
  chrome.tabs.query window-id: window-id, (tabs) !->
    tab-ids = tabs.map (tab) -> tab.id.to-string!
    tab-ids.for-each (tab-id) !->
      chrome.storage.local.remove tab-id

chrome.runtime.on-installed.add-listener initialize-extension
chrome.runtime.on-message.add-listener handle-message
chrome.tabs.on-updated.add-listener (tab-id, change-info, tab) !->
  if change-info.status == \loading
    url = tab.url
    if url.match /^https?:\/\/(\w|-)+(\.\w+){1,4}\//
      get-kotodama(url, tab-id)
chrome.tabs.on-removed.add-listener remove-tab-cache
chrome.windows.on-removed.add-listener remove-window-cache

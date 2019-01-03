firebase.initializeApp(config)

initialize-extension = !->
  browser.storage.local.clear
  extension-options = ng-list: false, colorful-kotodama: true
  browser.storage.local.set extension-options
  browser.notifications.create({message: browser.i18n.get-message('greeting'), title: browser.i18n.get-message('extName'), type: 'basic', iconUrl: browser.extension.getURL("images/logo-48.png")})

handle-kotodama-badge = (amount, tab-id) !->
  badge-str = amount.to-string!
  if amount < 10
    badge-color = "hsla(220, 100%, 40%, 0.4)"
  else if amount < 100
    badge-color = "hsla(120, 100%, 40%, 0.4)"
  else if amount < 1000
    badge-color = "hsla(50, 100%, 40%, 0.4)"
  else
    badge-color = "hsla(0, 100%, 40%, 0.4)"
    if amount < 1000000
      badge-str = Math.floor amount / 1000 .to-string! + \k
    else
      badge-str = \xxx
  browser.browser-action.set-badge-text text: badge-str, tab-id: tab-id
  browser.browser-action.set-badge-background-color color: badge-color, tab-id: tab-id

handle-message = (req, sender, send-res) !->
  if req.type == 1
    send-kotodama req, send-res
  else if req.type == 2
    tab-id = sender.tab.id
    browser.storage.local.get tab-id.to-string! .then (obj) !->
      browser.tabs.send-message tab-id, obj[tab-id.to-string!].msgs

send-kotodama = (req, send-res) !->
  url-hash = md5 req.url
  firebase.database!.ref(url-hash).push req.msg, (err) !->
    if err
      console.log "something wrong happened!"
    else
      get-kotodama req.url, req.tab-id, true
  send-res true

get-kotodama = (url, tab-id, display=false) !->
  url-hash = md5 url.replace /(https?:|[./#&?+=]|www)/g, ""
  firebase.database!.ref(url-hash).once \value .then (snapshot) !->
    msgs = snapshot.val!
    msgs-arr = []
    msgs-amount = 0
    if msgs
      msgs-arr = Object.values msgs
      msgs-amount = msgs-arr.length
    handle-kotodama-badge msgs-amount, tab-id
    tab-info = {}
    tab-obj = msgs: msgs-arr, display: display
    tab-info[tab-id] = tab-obj
    browser.storage.local.set tab-info

remove-tab-cache = (tab-id) !->
  browser.storage.local.remove tab-id.to-string!

remove-window-cache = (window-id) !->
  browser.tabs.query window-id: window-id, (tabs) !->
    tab-ids = tabs.map (tab) -> tab.id.to-string!
    tab-ids.for-each (tab-id) !->
      browser.storage.local.remove tab-id

browser.runtime.on-installed.add-listener initialize-extension
browser.runtime.on-message.add-listener handle-message
browser.tabs.on-updated.add-listener (tab-id, change-info, tab) !->
  if change-info.status == \loading
    url = tab.url
    if url.match /^https?:\/\/(\w|-)+(\.\w+){1,4}\//
      get-kotodama(url, tab-id)
browser.tabs.on-removed.add-listener remove-tab-cache
browser.windows.on-removed.add-listener remove-window-cache

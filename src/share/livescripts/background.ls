firebase.initialize-app config

initialize-extension = !->
  browser.storage.local.clear
  noti-obj =
    message: browser.i18n.get-message \greeting
    title: browser.i18n.get-message \extName
    type: \basic
    icon-url: browser.extension.getURL \images/logo-48.png
  browser.notifications.create noti-obj

handle-kotodama-badge = (amount, tab-id) !-->
  badge-str = if amount < 1000
    "#{amount}"
  else if amount < 100_0000
    "#{Math.floor amount / 1000}k"
  else
    "xxx"
  badge-hue = if amount < 10
    220
  else if amount < 100
    120
  else if amount < 1000
    50
  else
    0
  badge-color = "hsla(#{badge-hue}, 100%, 40%, 0.4)"
  badge-obj =
    text: badge-str
    tab-id: tab-id
  badge-color-obj =
    color: badge-color
    tab-id: tab-id
  browser.browser-action.set-badge-background-color badge-color-obj
  browser.browser-action.set-badge-text badge-obj

handle-message = (req, sender, send-res) !->
  switch req.type
  case 1
    send-kotodama(req)(send-res)
  case 2
    storage-get(sender.tab.id)((obj) !->
      browser.tabs.send-message sender.tab.id, obj[sender.tab.id].msgs)

send-kotodama = (req, send-res) !-->
  url-hash = md5 req.url
  firebase.database!.ref url-hash .push req.msg, (err) !->
    if err
      console.log "something wrong happened!"
    else
      get-kotodama(req.url)(req.tab-id)(false)
  send-res true

get-kotodama = (url, tab-id, reset-status) !-->
  url-hash = md5 url.replace /(https?:|[./#&?+=]|www)/g, ''
  firebase.database!.ref url-hash .once \value .then (snapshot) !->
    msgs-obj = snapshot.val!
    msgs-arr = if msgs-obj then Object.values msgs-obj else []
    msgs-amount = msgs-arr.length
    handle-kotodama-badge(msgs-amount)(tab-id)
    storage-get(tab-id)((obj) !->
      tabs-info = {}
      display = if reset-status || not obj[tab-id] then false else obj[tab-id].display
      tab-obj =
        msgs: msgs-arr
        display: display
      tabs-info[tab-id] = tab-obj
      browser.storage.local.set tabs-info)

get-kotodama-trigger = (tab-id, change-info, tab) !->
  if change-info.status == \complete
    url = tab.url
    if url.match /^https?:\/\/(\w|-)+(\.\w+){1,4}\//
      get-kotodama(url)(tab-id)(true)

remove-tab-cache = (tab-id) !->
  browser.storage.local.remove "#{tab-id}"

remove-window-cache = (window-id) !->
  browser.tabs.query window-id: window-id, (tabs) !->
    tab-ids = tabs.map (tab) -> "#{tab-id}"
    tab-ids.for-each (tab-id) !->
      browser.storage.local.remove tab-id

browser.runtime.on-installed.add-listener initialize-extension
browser.runtime.on-message.add-listener handle-message
browser.tabs.on-updated.add-listener get-kotodama-trigger
browser.tabs.on-removed.add-listener remove-tab-cache
browser.windows.on-removed.add-listener remove-window-cache

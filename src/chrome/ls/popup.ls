k-field = document.get-element-by-id \kotodama-field
k-on = document.get-element-by-id \kotodama-on
k-off = document.get-element-by-id \kotodama-off

(!->
  k-field.placeholder = chrome.i18n.get-message \placeholderShort)!

init-kotodama-switch = !->
  chrome.tabs.query active: true, current-window: true , (tabs) !->
    tab-id = tabs.0.id.to-string!
    chrome.storage.local.get tab-id,(obj) !->
      if obj[tab-id][\display] == true
        k-on.class-list.add \activated
      else
        k-off.class-list.add \activated
        
send-kotodama = (e) !->
  if e.key-code == 13
    e.target.set-attribute \disabled, true
    chrome.tabs.query active: true, current-window: true , (tabs) !->
      url = tabs.0.url.replace /(https?:|[./#&?+=]|www)/g, ''
      chrome.runtime.send-message type: 1, msg: e.target.value, url: url, tab-id: tabs.0.id, !->
        e.target.remove-attribute \disabled
        e.target.value = ''
        e.target.focus!

expand-field = (e) !->
  k-field.class-list.add \activated
  k-field.placeholder = chrome.i18n.get-message \placeholderLong

toggle-kotodama-screen = (e) !->
  chrome.tabs.query active: true, current-window: true , (tabs) !->
    chrome.storage.local.get tabs.0.id.to-string!, (obj) !->
      if obj[tabs.0.id.to-string!][\display] == true
        k-off.class-list.add \activated
        k-on.class-list.remove \activated
        obj[tabs.0.id.to-string!][\display] = false
        chrome.storage.local.set obj
        chrome.tabs.execute-script null, file: '/js/turn-off.js'
      else
        k-off.class-list.remove \activated
        k-on.class-list.add \activated
        obj[tabs.0.id.to-string!][\display] = true
        chrome.storage.local.set obj
        chrome.tabs.execute-script null, file: 'js/turn-on.js'
        
k-field.add-event-listener \keypress, send-kotodama
k-field.add-event-listener \mousedown, expand-field
k-on.add-event-listener \mousedown, toggle-kotodama-screen
k-off.add-event-listener \mousedown, toggle-kotodama-screen
init-kotodama-switch!

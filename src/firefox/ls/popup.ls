k-field = document.get-element-by-id \kotodama-field
k-on = document.get-element-by-id \kotodama-on
k-off = document.get-element-by-id \kotodama-off
len-alert = document.get-element-by-id \length-alert

(!->
  k-field.placeholder = browser.i18n.get-message \placeholderShort)!

init-kotodama-switch = !->
  browser.tabs.query active: true, current-window: true , (tabs) !->
    tab-id = tabs.0.id.to-string!
    browser.storage.local.get tab-id,(obj) !->
      if obj[tab-id][\display] == true
        k-on.class-list.add \activated
      else
        k-off.class-list.add \activated

limit-length = (e) !->
  if e.key-code != 13
    set-timeout !->
      available-len = 80 - new TextEncoder('utf-8').encode e.target.value .length
      len-alert.inner-text = browser.i18n.get-message(\lengthAlert) + available-len
      if available-len >= 50
        len-alert.class-name = \safe
      else if available-len >= 20
        len-alert.class-name = \warning
      else
        len-alert.class-name = \alert
      if available-len <= 0
        e.target.set-attribute \disabled
      else
        e.target.remove-attribute \disabled
    , 0

send-kotodama = (e) !->
  if e.key-code == 13 && new TextEncoder \utf-8 .encode e.target.value .length <= 80
    e.target.set-attribute \disabled, true
    browser.tabs.query active: true, current-window: true , (tabs) !->
      url = tabs.0.url.replace /(https?:|[./#&?+=]|www)/g, ''
      browser.runtime.send-message type: 1, msg: e.target.value, url: url, tab-id: tabs.0.id
        .then (obj) !->
          e.target.remove-attribute \disabled
          e.target.value = ''
          e.target.focus!
          len-alert.inner-text = ''
      
expand-field = (e) !->
  k-field.class-list.add \activated
  k-field.placeholder = browser.i18n.get-message \placeholderLong
  
toggle-kotodama-screen = (e) !->
  browser.tabs.query active: true, current-window: true , (tabs) !->
    browser.storage.local.get tabs.0.id.to-string!, (obj) !->
      if obj[tabs.0.id.to-string!][\display] == true
        k-off.class-list.add \activated
        k-on.class-list.remove \activated
        obj[tabs.0.id.to-string!][\display] = false
        browser.storage.local.set obj
        browser.tabs.execute-script null, file: '/js/turn-off.js'
      else
        k-off.class-list.remove \activated
        k-on.class-list.add \activated
        obj[tabs.0.id.to-string!][\display] = true
        browser.storage.local.set obj
        browser.tabs.execute-script null, file: '/js/turn-on.js'
        
k-field.add-event-listener \keypress, send-kotodama
k-field.add-event-listener \keydown, limit-length
k-field.add-event-listener \mousedown, expand-field
k-on.add-event-listener \mousedown, toggle-kotodama-screen
k-off.add-event-listener \mousedown, toggle-kotodama-screen
init-kotodama-switch!

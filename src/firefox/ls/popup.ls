k-field = document.get-element-by-id \kotodama-field
k-on = document.get-element-by-id \kotodama-on
k-off = document.get-element-by-id \kotodama-off

init-kotodama-switch = !->
  browser.tabs.query active: true, current-window: true , (tabs) !->
    tab-id = tabs.0.id.to-string!
    browser.storage.local.get tab-id,(obj) !->
      if obj[tab-id][\display] == true
        k-on.class-list.add \activated
      else
        k-off.class-list.add \activated
        
send-kotodama = (e) !->
  if e.key-code == 13
    e.target.set-attribute \disabled, true
    browser.tabs.query active: true, current-window: true , (tabs) !->
      url = tabs.0.url.replace(/https?:\/\/|\.|\/|www|#/g,'')
      browser.runtime.send-message {msg: e.target.value, url: url, tab-id: tabs.0.id}
        .then (obj) !->
          e.target.remove-attribute \disabled
          e.target.value = ''
      
expand-field = (e) !->
  k-field.class-list.add \activated
  k-field.placeholder = 'your kotodama here'
  
toggle-kotodama-screen = (e) !->
  browser.tabs.query active: true, current-window: true , (tabs) !->
    browser.storage.local.get tabs.0.id.to-string!, (obj) !->
      if obj[tabs.0.id.to-string!][\display] == true
        k-off.class-list.add \activated
        k-on.class-list.remove \activated
        obj[tabs.0.id.to-string!][\display] = false
        browser.storage.local.set obj
      else
        k-off.class-list.remove \activated
        k-on.class-list.add \activated
        obj[tabs.0.id.to-string!][\display] = true
        browser.storage.local.set obj
        
k-field.add-event-listener \keypress, send-kotodama
k-field.add-event-listener \mousedown, expand-field
k-on.add-event-listener \mousedown, toggle-kotodama-screen
k-off.add-event-listener \mousedown, toggle-kotodama-screen
init-kotodama-switch!

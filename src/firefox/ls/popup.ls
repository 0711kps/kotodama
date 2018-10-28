h-res = (res) ->
  console.log "kotodama successfully sent."
h-err = (err) ->
  console.log "kotodama fail to send."

k-field = document.get-element-by-id "k-field"
k-field.focus!
k-field.add-event-listener 'keypress', (e) ->
  if e.key-code == 13
    browser.tabs.query active: true, current-window: true , (tabs) !->
      url = tabs.0.url.replace(/(https?:\/\/)|\.|\//g,'')
      sending = browser.runtime.send-message msg: e.target.value, url: url
      sending.then(h-res, h-err)

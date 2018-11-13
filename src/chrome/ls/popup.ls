k-field = document.get-element-by-id "k-field"
k-field.add-event-listener 'keypress', (e) ->
  if e.key-code == 13
    chrome.tabs.query active: true, current-window: true , (tabs) !->
      url = tabs.0.url.replace(/https?:\/\/|\.|\/|www|#/g,'')
      sending = chrome.runtime.send-message {msg: e.target.value, url: url, tab-id: tabs.0.id}

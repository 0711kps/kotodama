k-field = document.get-element-by-id \kotodama-field
k-on = document.get-element-by-id \kotodama-on
k-off = document.get-element-by-id \kotodama-off
len-alert = document.get-element-by-id \length-alert
k-len-limit = 100

toggle-switch = (target, status) !-->
  if status
    target.class-list.add \activated
  else
    target.class-list.remove \activated

init-kotodama-switch = !->
  tabs-condition =
    active: true
    current-window: true
  browser.tabs.query tabs-condition , (tabs) !->
    storage-get(tabs.0.id)((obj) !->
      target-icon = if obj[tabs.0.id].display then k-on else k-off
      toggle-switch(target-icon)(true))

limit-length = (e) !->
  if e.key-code != 13
    set-timeout !->
      available-len = k-len-limit - new TextEncoder 'UTF-8' .encode e.target.value .length
      len-alert.inner-text = "#{browser.i18n.get-message \lengthAlert}#{available-len}"
      len-alert.class-name = if available-len >= 50
        \safe
      else if available-len >= 30
        \warning
      else
        \alert
    , 0

send-kotodama = (e) !->
  if e.key-code == 13 && new TextEncoder \UTF-8' .encode e.target.value .length <= k-len-limit
    e.target.set-attribute \disabled, true
    tabs-condition =
      active: true
      current-window: true
    browser.tabs.query tabs-condition , (tabs) !->
      url = tabs.0.url.replace /(https?:|[./#&?+=]|www)/g, ''
      msg-obj =
        type: 1
        msg: e.target.value
        url: url
        tab-id: tabs.0.id
      runtime-send-msg msg-obj, !->
        e.target.remove-attribute \disabled
        e.target.value = ''
        e.target.focus!
        len-alert.inner-text = browser.i18n.get-message \sendComplete
        set-timeout !->
          len-alert.inner-text = ''
        , 1000

expand-field = (e) !->
  k-field.class-list.add \activated
  k-field.placeholder = browser.i18n.get-message \placeholderLong
  set-timeout !->
    k-field.focus!
  , 500

toggle-kotodama-screen = (e) !->
  tabs-condition =
    active: true
    current-window: true
  browser.tabs.execute-script null, file: '/javascripts/browser-init.js'
  browser.tabs.query tabs-condition , (tabs) !->
    storage-get(tabs.0.id)((obj) !->
      [target1, target2, target-status] = if obj[tabs.0.id].display then [k-on, k-off, 'off'] else [k-off, k-on, 'on']
      obj[tabs.0.id].display = !obj[tabs.0.id].display
      browser.storage.local.set obj
      toggle-switch(target1)(false)
      set-timeout !->
        toggle-switch(target2)(true)
      , 200
      browser.tabs.execute-script null, file: "/javascripts/turn-#{target-status}.js")

(!->
  k-field.placeholder = browser.i18n.get-message \placeholderShort)!

k-field.add-event-listener \keypress, send-kotodama
k-field.add-event-listener \keydown, limit-length
k-field.add-event-listener \mousedown, expand-field
k-on.add-event-listener \mousedown, toggle-kotodama-screen
k-off.add-event-listener \mousedown, toggle-kotodama-screen
init-kotodama-switch!

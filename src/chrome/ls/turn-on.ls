k-screen = document.get-element-by-id \kotodama-screen
## k-init = (msgs) ->
## k-start = (k-object) !->
##   console.log k-oject
if !k-screen
  k-screen = document.create-element \div
  k-screen.set-attribute \id, \kotodama-screen
  document.body.append k-screen

k-screen.class-list.add \exist
set-timeout !->
  k-screen.class-list.add \activated
, 100

chrome.runtime.send-message type: 2
get-msgs = (msgs) !->
  chrome.runtime.on-message.remove-listener get-msgs
  if msgs.length
    i = 0
    msgs.for-each (msg) !->
      kotodama = document.create-element \div
      { random, floor } = Math
      color = (floor(random! * 13)+1) * 24
      kotodama
        ..inner-text = msg
        ..class-list = 'untouchable kotodama'
        ..style.color = "hsl(#{color}, 100%, 70%)"
      k-screen.append kotodama
      set-timeout !->
        kotodama.class-list.add \flying
      , (2500 * i) + 100
      set-timeout !->
        kotodama.remove!
      , (2500 * i) + 100 + 4000
      i++
  else
    alert-div = document.create-element \div
    alert-div
      ..id = \empty-alert
      ..class-list = \untouchable
      ..inner-text = chrome.i18n.get-message \emptyAlert
    set-timeout !->
      k-screen.append alert-div
    , 200

chrome.runtime.on-message.add-listener get-msgs

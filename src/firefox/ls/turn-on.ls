k-screen = document.get-element-by-id \kotodama-screen
if !k-screen
  k-screen = document.create-element \div
  k-screen.set-attribute \id, \kotodama-screen
  document.body.append k-screen

k-screen.class-list.add \exist
set-timeout !->
  k-screen.class-list.add \activated
, 100

browser.runtime.send-message type: 2
get-msgs = (msgs) !->
  browser.runtime.on-message.remove-listener get-msgs
  if msgs.length
    msgs.for-each (msg) !->
      kotodama = document.create-element \div
      { random, floor } = Math
      color = (random! * 13) * 24
      kotodama
        ..inner-text = msg
        ..class-list = 'untouchable kotodama'
        ..style.color = "hsl(#{color}, 80%, 50%)"
      k-screen.append kotodama
      set-timeout !->
        kotodama.class-list.add \flying
      , 100
      set-timeout !->
        kotodama.remove!
      , 6100
  else
    alert-div = document.create-element \div
    alert-div
      ..id = \empty-alert
      ..class-list = \untouchable
      ..inner-text = browser.i18n.get-message \emptyAlert
    k-screen.append alert-div

browser.runtime.on-message.add-listener get-msgs

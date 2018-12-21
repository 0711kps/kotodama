k-screen = document.get-element-by-id \kotodama-screen
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
    console.log msgs
  else
    alert-div = document.create-element \div
    alert-div.set-attribute \id, \empty-alert
    alert-div.inner-text = chrome.i18n.get-message \emptyAlert
    k-screen.append alert-div

chrome.runtime.on-message.add-listener get-msgs

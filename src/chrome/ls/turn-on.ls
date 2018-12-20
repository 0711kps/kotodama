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
  console.log msgs
chrome.runtime.on-message.add-listener get-msgs

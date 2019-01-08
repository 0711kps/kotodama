k-screen = document.get-element-by-id \kotodama-screen
alert-div = document.get-element-by-id \empty-alert
k-screen.class-list.remove \activated
if alert-div
  alert-div.remove!
set-timeout !->
  timers.for-each (timer) !->
    clear-timeout timer
  k-screen.class-list.remove \exist
  while k-screen.child-element-count
    k-screen.children.0.remove!
, 200


k-screen = document.get-element-by-id \kotodama-screen

cal-time = (msg) ->
  len = new TextEncoder 'utf-8' .encode msg .length
  basic-dur = Math.ceil document.body.get-client-rects!.0.width / 350
  if len < 30
    dur = basic-dur
  else
    dur = basic-dur + (len-30) * 15 / 100
  dur: dur
  delay: Math.floor(dur * Math.random! * 8 + 4) / 10

random-color = ->
  hue = (Math.floor(Math.random! * 15) * 24)
  "hsl(#{hue}, 100%, 70%)"

generate-kotodamas = (msgs) ->
  msgs.map (msg) ->
    { dur, delay } = cal-time msg
    text: msg
    duration: dur
    delay: delay
    color: random-color!

init-rails = ->
  rail-height = Math.floor document.body.get-client-rects!.0.height / 10
  rails = [1 to 8].map (i) ->
    pos-y: rail-height * i
    total-delay: 0
    kotodamas: []

fill-rails = (rails, kotodamas) ->
  while kotodamas.length
    next-kotodama = kotodamas.shift!
    (rails.sort (rail, next-rail) ->
      rail.total-delay > next-rail.total-delay).0
        ..kotodamas.push next-kotodama
        ..total-delay += next-kotodama.delay
  rails.for-each (rail) !->
    [0 til rail.kotodamas.length].for-each (i) !->
      j = Math.floor Math.random! * rail.kotodamas.length
      [rail.kotodamas[i], rail.kotodamas[j]] = [rail.kotodamas[j], rail.kotodamas[i]]
  rails

shoot-kotodama = (rail) !->
  k-attrs = rail.kotodamas.shift!
  kotodama = document.create-element \div
  kotodama
    ..inner-text = k-attrs.text
    ..class-list = 'untouchable kotodama'
    ..style
      ..color = k-attrs.color
      ..top = "#{rail.pos-y}px"
      ..animation-duration = "#{k-attrs.duration}s"
  k-screen.append kotodama
  set-timeout !->
    kotodama.class-list.add \flying-m
  , 100
  ## set-timeout !->
  ##   kotodama.remove!
  ## , 100 + k-attrs.duration * 1000
  if rail.kotodamas.length
    set-timeout !->
      shoot-kotodama rail
    , 100 + k-attrs.delay * 1000

k-start = (msgs) !->
  sorted-kotodamas = generate-kotodamas msgs .sort (kotodama) -> kotodama.duration
  empty-rails = init-rails!
  filled-rails = fill-rails empty-rails, sorted-kotodamas
  filled-rails.for-each (rail) !->
    set-timeout !->
      shoot-kotodama rail
    , 0

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
    k-start msgs
  else
    alert-div = document.create-element \div
    alert-div
      ..id = \empty-alert
      ..class-list = \untouchable
      ..inner-text = browser.i18n.get-message \emptyAlert
    set-timeout !->
      k-screen.append alert-div
    , 200

browser.runtime.on-message.add-listener get-msgs

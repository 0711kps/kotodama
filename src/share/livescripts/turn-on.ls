k-screen = document.get-element-by-id \kotodama-screen

timers = []

cal-time = (msg) ->
  len = new TextEncoder 'UTF-8' .encode msg .length
  basic-dur = Math.ceil window.inner-width / 280
  dur = basic-dur + if len < 30 then 0 else (len-30) * 25 / 100
  dur: dur
  delay: Math.floor(dur * Math.random! * 9 + 9) / 10

random-color = ->
  hue = Math.floor(Math.random! * 15) * 24
  "hsl(#{hue}, 100%, 70%)"

random-size = ->
  size-num = (Math.floor Math.random! * 2) + 1
  "x#{size-num}"

generate-kotodamas = (msgs) ->
  msgs.map (msg) ->
    { dur, delay } = cal-time msg
    text: msg
    duration: dur
    delay: delay
    color: random-color!
    size: random-size!

init-rails = ->
  rail-height = Math.floor window.inner-height / 10
  rails = [1 to 8].map (i) ->
    pos-y: rail-height * i
    total-delay: 0
    kotodamas: []

fill-rails = (rails, kotodamas) -->
  while kotodamas.length
    next-kotodama = kotodamas.shift!
    (rails.sort (rail, next-rail) ->
      rail.total-delay - next-rail.total-delay).0
        ..kotodamas.push next-kotodama
        ..total-delay += next-kotodama.delay
  rails.for-each (rail) !->
    [0 til rail.kotodamas.length].for-each (i) !->
      j = Math.floor Math.random! * rail.kotodamas.length
      [rail.kotodamas[i], rail.kotodamas[j]] = [rail.kotodamas[j], rail.kotodamas[i]]
  rails.filter (rail) -> rail.kotodamas.length

shoot-kotodama = (rail) !->
  k-attrs = rail.kotodamas.shift!
  kotodama = document.create-element \div
  fly-type = (Math.floor Math.random! * 7) + 1
  fly-motion = "flying-#{fly-type}"
  kotodama
    ..inner-text = k-attrs.text
    ..class-list = "untouchable kotodama #{k-attrs.size}"
    ..style
      ..color = k-attrs.color
      ..top = "#{rail.pos-y}px"
      ..animation-duration = "#{k-attrs.duration}s"
  k-screen.append kotodama
  timers.push set-timeout !->
    kotodama.class-list.add fly-motion
  , 100
  timers.push set-timeout !->
    kotodama.remove!
  , 100 + k-attrs.duration * 1000
  if rail.kotodamas.length
    timers.push set-timeout !->
      shoot-kotodama rail
    , 100 + k-attrs.delay * 1000

k-start = (msgs) !->
  sorted-kotodamas = generate-kotodamas msgs .sort (kotodama) -> kotodama.duration
  empty-rails = init-rails!
  filled-rails = fill-rails empty-rails, sorted-kotodamas
  filled-rails.for-each (rail) !->
    timers.push set-timeout !->
      shoot-kotodama rail
    , (Math.floor Math.random! * 6) * 500

unless k-screen
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

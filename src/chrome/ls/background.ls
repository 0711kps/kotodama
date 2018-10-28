config =
  apiKey: "AIzaSyDoAKfpxq4whB8Im7wbT2fw27FR8iDjI9g"
  authDomain: "kotodama-0711.firebaseapp.com"
  databaseURL: "https://kotodama-0711.firebaseio.com"
  projectId: "kotodama-0711"
  storageBucket: "kotodama-0711.appspot.com"
  messagingSenderId: "1053544726845"
firebase.initializeApp(config)

send-kotodama = (req, sender, send-res) !->
  firebase.database!.ref(req.url).push req.msg
  send-res true

chrome.runtime.on-message.add-listener send-kotodama

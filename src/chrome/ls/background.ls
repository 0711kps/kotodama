chrome.runtime.on-installed.add-listener !->
  xhr = new XML-http-request!
  xhr.open 'GET' 'https://www.google.com.tw'
  xhr.onload = !->
    if xhr.status == 200
      console.log "get something from google"
      console.log xhr
    else
      console.log "fail ajax"
  xhr.send!

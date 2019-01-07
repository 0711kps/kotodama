browser = chrome
storage-get = (tab-id, func) !-->
  browser.storage.local.get "#{tab-id}" , func
runtime-send-msg = (obj, func) !-->
  browser.runtime.send-message obj, func

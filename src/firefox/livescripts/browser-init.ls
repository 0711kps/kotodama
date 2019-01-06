storage-get = (tab-id, func) !-->
  browser.storage.local.get "#{tab-id}" .then(func)
runtime-send-msg = (obj, func) !-->
  browser.runtime.send-message obj
    .then func


clbk = ->
  window.refresher_loaded = true
setTimeout(clbk , 4000);

class Dashing.Refresher extends Dashing.Widget

  onData: (data) ->
    if(window.refresher_loaded)
      document.location.reload(true)

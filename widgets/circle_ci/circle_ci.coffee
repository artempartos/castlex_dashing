class Dashing.CircleCi extends Dashing.Widget
  @accessor 'coverage', Dashing.AnimatedValue

  onData: (data) ->
    @_checkStatus(data.widget_class)

  _checkStatus: (status) ->
    $(@node).removeClass('failed pending passed')
    $(@node).addClass(status)

  constructor: ->
    super
    @observe 'coverage', (value) ->
      $(@node).find(".meter").val(value).trigger('change')

  ready: ->
    meter = $(@node).find(".meter")
    meter.attr("data-bgcolor", meter.css("background-color"))
    meter.attr("data-fgcolor", meter.css("color"))
    meter.knob()

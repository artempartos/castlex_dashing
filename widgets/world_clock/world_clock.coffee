class Dashing.WorldClock extends Dashing.Widget
  ready: ->
    setInterval(@startTime, 500)

  startTime: =>
    today = moment(new Date()).tz(@get('timezone'))
    @set('time', today.format('H:mm'))
    @set('date', today.format("ddd MMM DD YYYY"))

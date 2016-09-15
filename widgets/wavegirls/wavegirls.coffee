class Dashing.Wavegirls extends Dashing.Widget

  ready: ->
    @preloadGirls()
    @currentIndex = 0
    @dashes = []
    @mode = 'default'

    @load_dashes()
    setTimeout(@load_dashes, 3000)

    @girlElem = $(@node).find('.wavegirl-container')
    @nextGirl()
    @startCarousel()

  # Returns dashes which can be used for showing images
  load_dashes: =>
    @dashes = []

    for widget_name in Object.getOwnPropertyNames(Dashing.widgets)
      continue if widget_name == "wavegirls"
      for dash in Dashing.widgets[widget_name]
        # specify any other widgets you do not want to show images
        excluded_dash_ids = ['player', 'youtube', 'pic', 'slideshare', 'refresher']
        if dash.id not in excluded_dash_ids
          @dashes.push dash.node

  fryGirl: (e) ->
    girl = {}
    girl.image = e.target
    girl.ratio = girl.image.naturalWidth / girl.image.naturalHeight
    @loadedGirlsArray.push girl
    girl.resetCss = ->
      $(this.image).css
        'maxWidth': 'none'
        'maxHeight': 'none'
        'width': 'auto'
        'height': 'auto'
        'marginLeft': 0
        'marginTop': 0
    girl.pull = (dash, mode, girlElem) ->
      if (mode == 'fullscreen')
        $('.gridster').fadeOut =>
          $('#wavegirls-img').fadeIn()
          image = this.image

          $(image).css
            'height': '100%'
            'width': 'auto'

          $("#wavegirls-img").append girlElem
      else
        $('.gridster').fadeIn =>
          this.resetCss
          dashRatio = parseInt(dash.width()) / parseInt(dash.height())
          if dashRatio > girl.ratio
            $(this.image).css
              'width': dash.outerWidth() + 'px'
          else
            $(this.image).css
              'height': dash.outerHeight() + 'px'
          if dashRatio > girl.ratio
            $(this.image).css
              'marginTop': '-' + (((dash.outerWidth() / girl.ratio) - dash.outerHeight()) / 2) + 'px'
          else
            $(this.image).css
              'marginLeft': '-' + (((dash.outerHeight() / girl.ratio) - dash.outerWidth()) / 2) + 'px'
          dash.append girlElem

  preloadGirls: ->
    @preloadGirlsArray = []
    @loadedGirlsArray = []
    if @get('wavegirls')
      for girlUrl in @get('wavegirls')
        @preloadGirlsArray.push(
          $(new Image()).attr({'src': girlUrl}).one("load", $.proxy(@fryGirl, @)).each ->
            $(this).load() if @complete
        )

  onData: (data) ->
    if data.wavegirls
      @currentIndex = 0
      @preloadGirls()
    if data.mode
      @mode = data.mode

  startCarousel: ->
    setInterval(@nextGirl, 5000)

  nextGirl: =>
    @girls = @loadedGirlsArray
    if @girls.length > 0
      @girlElem.fadeOut =>
        @girlElem.detach()
        if @mode == 'default'
          $('.gridster').fadeIn()
          return

        @currentIndex = (@currentIndex + 1) % @girls.length
        girl = @girls[@currentIndex]
        dash = $(@dashes[Math.floor(Math.random() * @dashes.length)])

        @girlElem.find('img:last').detach()
        girl.pull(dash, @mode, @girlElem)
        @set 'current_wavegirl', @girlElem
        @girlElem.append girl.image
        @girlElem.fadeIn()

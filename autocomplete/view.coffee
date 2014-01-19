@MyApp.module 'Components.Autocomplete', (Autocomplete, App, Backbone, Marionette, $, _) ->

  Autocomplete.Element = App.Views.ItemView.extend
    tagName: 'li'
    template: 'components/autocomplete/templates/element'
    triggers: {'click': 'on:select'}

  Autocomplete.List = App.Views.CollectionView.extend
    className: 'autocomplete'
    tagName: 'ul'
    minKeywordLength: 2
    itemView: Autocomplete.Element

    collectionEvents:
      'sync': '_setListVisibility'

    initialize: (options) ->
      _.extend @, _.omit(options, 'collection')
      @hide = _.debounce(@hide, 100)

    onShow: ->
      @_setCSS()
      @_setCallbacks()

    _setListVisibility: ->
      return @show() if @collection.length
      @hide()

    _setCSS: ->
      @$target.attr 'autocomplete', 'off'
      @$el.width @$target.outerWidth()

    _setCallbacks: ->
      @$target.on 'keydown', (e) => @keyDown(e)
      @listenTo @, 'itemview:on:select', @_select
      @$target.on 'blur', => @hide()

    _select: (itemview) ->
      label = itemview.model.get('name')
      tags = @_createKeywordsString(label)
      @$target.val(tags)
      @hide()

    _createKeywordsString: (label) ->
      return label unless @multipleWords
      inputVal = @$target.val()
      cursor = @_getCursorPosition()
      lastComma = inputVal.lastIndexOf(',', cursor)

      if lastComma isnt -1 then label = " #{label}"
      inputVal.substr(0, lastComma + 1) + label + inputVal.substr(cursor)

#####################################

    keyDown: (event) ->
      return @hide() if [27, 188, 9].indexOf(event.keyCode) isnt -1
      switch event.keyCode
        when 38 then @move(-1)
        when 40 then @move(+1)
        when 13 then @onEnter(event)
        else @onType()

    onType: ->
      keyword = @_getCurrentKeyword()
      return @hide() unless @_isValid(keyword)
      @_filter(keyword)

    _getCurrentKeyword: ->
      inputVal = @$target.val()
      return inputVal unless @multipleWords
      cursor = @_getCursorPosition()
      lastComma = inputVal.lastIndexOf(',', cursor)
      inputVal.substr(lastComma + 1, cursor).trim()

    _getCursorPosition: ->
      @$target[0].selectionStart

    move: (position) ->
      current = @$el.children('.active')
      siblings = @$el.children()
      index = current.index() + position
      if siblings.eq(index).length
        current.removeClass 'active'
        siblings.eq(index).addClass 'active'
      false

    onEnter: (e) ->
      e.preventDefault()
      @$el.children('.active').click()

    hide: ->
      @$el.hide()

    show: ->
      @$el.show()

    _isValid: (keyword) ->
      !!(keyword.length > @minKeywordLength)

    _filter: (keyword) ->
      @trigger 'filter:results', keyword
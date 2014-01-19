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
      @filter = _.debounce(@filter, 300)

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
      @$target.val(label)
      @hide()

#####################################

    keyDown: (event) ->
      switch event.keyCode
        when 38 then @move(-1)
        when 40 then @move(+1)
        when 13 then @onEnter(event)
        when 27 then @hide()
        when 9 then @hide()
        else @onType()

    onType: ->
      keyword = @$target.val()
      return @hide() unless @_isValid(keyword)
      @_filter(keyword)

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
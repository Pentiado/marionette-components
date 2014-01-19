@MyApp.module 'Components.Autocomplete', (Autocomplete, App, Backbone, Marionette, $, _) ->

  class Autocomplete.Controller extends App.Controllers.Base
    queryParameter: 'inname'

    initialize: (options) ->
      _.extend @, _.pick(options, 'queryParameter')
      collection = @_getCollection()
      @view = @_getView(collection, options)
      @show(@view)
      @_setCallbacks()

    _getCollection: ->
      Autocomplete.API.list()

    _getView: (collection, options) ->
      new Autocomplete.List
        collection: collection
        $target: options.$target

    _setCallbacks: ->
      @listenTo @view, 'filter:results', @filterResults

    filterResults: (keyword) ->
      keyword = keyword.toLowerCase()
      parameters =
        page: 1
        pagesize: 5
        order: 'desc'
        sort: 'popular'
        site: 'stackoverflow'

      parameters[@queryParameter] = keyword

      @view.collection.fetch
        data: parameters
        dataType: 'jsonp'

    destroy: ->
      App.removeRegion()
      @view.close()

    onClose: ->
      App.removeRegion(@region)
      super

##############################################

  Autocomplete.RegionManager = new Marionette.RegionManager()

  Autocomplete.RegionManager.on 'region:remove', (name, region) ->
    $(region.el).remove()

  _.extend Autocomplete.RegionManager,
    createRegion: ($target) ->
      id = _.uniqueId('autocomplete-') + '-region'
      @_createRegionTag(id, $target)
      @_addRegionToManager(id)

    _createRegionTag: (id, $target) ->
      regionTag = $('<div></div>').attr {id: id}
      $target.after(regionTag)

    _addRegionToManager: (id) ->
      @addRegion(id, "##{id}")

##############################################

  App.reqres.setHandler 'autocomplete', ($target) ->
    region = Autocomplete.RegionManager.createRegion($target)
    new Autocomplete.Controller
      $target: $target
      region: region

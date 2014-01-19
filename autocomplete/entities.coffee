@MyApp.module 'Components.Autocomplete', (Autocomplete, App, Backbone, Marionette, $, _) ->

  Autocomplete.Model = App.Entities.Model.extend()

  Autocomplete.Collection = App.Entities.Collection.extend
    model: Autocomplete.Model
    url: 'https://api.stackexchange.com/2.1/tags'
    parse: (response) ->
      response.items

  Autocomplete.API =

    list: ->
      collection = new Autocomplete.Collection
      collection
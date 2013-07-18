define [
    'jquery'
    'backbone'
], (
    $
    Backbone
) ->

    class AutocompleteView extends Backbone.View

        #### Autocomplete View  ####
        #
        #     A generic autocomplete list view. Handles
        #     Select(hover/up arrow/down arrow) events and
        #     Choose (enter, click) events, while delegating
        #     the handling of those to a parent View. We can
        #     pass generic collections and models to populate
        #     the autocomplete, and set seperate handlers in a
        #     Parent view.
        #
        # USAGE: In parent view, initialize autocomplete view with
        # these options.
        #
        #     el: The list element which contains list items
        #
        #     collection: The collection to populate the
        #     autocomplete list with.
        #
        #     template:
        #
        #         listItemTemplate: Template for each list
        #         item, as a function (Jade)
        #
        #         locals: A function that takes a model and
        #         returns a locals object that can be passed
        #         to the template
        #
        #     getLabel: A function which takes a model, and
        #     returns value that should be returned on item
        #     select for display in input.
        #
        #     matchOn: A function which takes a model, and
        #     returns a value that you want the autocomplete
        #     matcher to match on
        #
        #     handlers:
        #
        #         itemSelectedHandler: Handler function for
        #         item select event. Takes a model.
        #
        #         itemChosenHandler: Handler function for
        #         item choose event. Takes a model.
        #
        #
        # PUBLIC METHODS:
        #
        #     updateTerm(term): Takes a term, filters
        #     collection on term using provided
        #     matchOn(model) method, and updates the list.
        #
        #     unChooseItem(id): Takes a model id, restores
        #     that model to the original collection.
        #
        #
        #####


        # The maximum number of list items to show in the
        # autocomplete list.
        maxListLength: 4


        ## Initialization
        initialize: (options) ->
            _.bindAll()

            # Bind all options to 'this' (we need them all)
            _.each options, ((v,k) -> this[k]=v),this

            @chosenCollection = new Backbone.Collection()




        #### Methods that interact with parent view ####

        ## Called by parent view:
        ## Given an autocomplete term, filter the
        ## collection and display those items. Applies
        ## configured matchOn method to test against term
        updateTerm: (term) ->
            regex = new RegExp(@escapeRegex(term),"i")
            data = @collection.filter(
                (model) -> regex.test(@matchOn(model))
                this)
            @updateList(data)


        ## Called by parent view:
        ## Handler for choosing an item
        unChooseItem: (id) ->
            model = @chosenCollection.get(id)
            if model?
                @chosenCollection.remove(model)
                @collection.add model


        ## Handler for choosing an item
        chooseItem: ($item) ->
            id = $item.attr 'data-id'
            model = @collection.get id
            @handlers.itemChosenHandler model
            @collection.remove model
            @chosenCollection.add model


        ## Handler for selecting an item
        selectItem: ($item) ->
            if @$selection?
                $oldSelection = @$selection.removeClass('is-list-item-selected')
            @$selection = $item.addClass('is-list-item-selected')

            model = @collection.get($item.attr('data-id'))
            @handlers.itemSelectedHandler model
            return $oldSelection




        ####  Handling Events ####

        ## Events
        events:
            'click .pnt-autocomplete-list-item'  : 'chooseItemOnClick'
            # TODO get mouse events to work
            #'click .autocomplete-list-item'      : 'clickedResult'
            #'mouseenter .autocomplete-list-item' : 'mouseOverResult'
            #'mouseleave .autocomplete-list-item' : 'mouseOutResult'


        ## Bind key and mouse events to document
        bindExternalEvents: ->
            $(window).bind 'keydown', @onKeydownBody

            # TODO mouse events
            #$(window).bind('mousemove', @rebindHover)
            #$(window).bind('click', @rebindHover)


        ## Handle keys that aren't neccessarily used when input is
        ## focused, like paging down and up the autocomplete
        onKeydownBody: (e) ->
            switch e.keyCode
                when 13 #enter
                    e.preventDefault()
                    @chooseSelectedItemOnEnter()
                when 38 #up
                    e.preventDefault()
                    @selectChangeOn('up')
                when 40 #down
                    e.preventDefault()
                    @selectChangeOn('down')


        ## Override Backbone.Views's remove.  Manually unbind anything
        ## that is bound in this method.  Then call super remove, which
        ## removes view from DOM, and calls stopListening to remove any
        ## bound events that the view has listenTo'd to.
        remove: ->
            $(window).unbind 'keydown', @onKeydownBody
            super()


        ## Update list with new data. The data is usually a
        ## subset of this.collection
        updateList: (data) ->

            # Empty list element
            @emptyListEl()

            # Return if no data
            return if data.length < 1

            # If we're going to limit the list, lets do it
            # here for performance
            data = _.first(data, @maxListLength)

            # Append items with updated data
            _.each data,
                (model) ->
                    listItem = @template.listItemTemplate(@template.locals(model))
                    @$el.append $(listItem).attr('data-id', model.id)
                this

            # Set selection to first list item
            @$selection =
                @$('.pnt-autocomplete-list-item')
                .first().addClass('is-list-item-selected')


        ## Empty the list, clear selection
        emptyListEl: ->
            @$el.html('')
            @$selection = null


        ## Event Handlers for clicking/enter-ing to choose
        ## an item, and call chooseItem on the element
        chooseSelectedItemOnEnter: (e) -> @chooseItem @$selection if @$selection?
        chooseItemOnClick: (e) ->  @chooseItem $(e.target)


        ## Given a direction 'up' or 'down' move to next or
        ## previous selected element in autocomplete list.
        ## If no next/prev, wrap around to first or last.
        selectChangeOn: (direction) ->

            return if direction not in ['up', 'down']

            # TODO: handle this hover stuff
            #@hoverEnabled = false

            # If something is selected
            if @$selection?

                # Get next or prev element
                $newSelection =
                    if direction == 'up' then @$selection.prev() else @$selection.next()

                if $newSelection.length > 0
                    $oldSelection = @selectItem($newSelection)
                    #if direction == 'up' then @scrollUp() else @scrollDown($oldSelection)

            else
                # If nothing already selected, select first or last
                if direction == 'up'
                    @selectItem @$el.find('.pnt-autocomplete-list-item').last()
                else
                    @selectItem @$el.find('.pnt-autocomplete-list-item').first()


        escapeRegex: (value) -> value.replace(/[\-\[\]{}()*+?.,\\\^$|#\s]/g, "\\$&")



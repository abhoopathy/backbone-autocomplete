# Autocomplete View

# TODO
- Mouse events
- Make inheritable

## Description

A generic autocomplete list view.

Takes generic collection of models to populate the
autocomplete. Handles Select(hover/up arrow/down arrow)
events and Choose (enter, click) events, while delegating
the handling of those to a parent View.

This gives you the flexibility to use an input,
contenteditable for multiple selections, or an 'omnibox'
(think twitter).



## Usages
In parent view, initialize autocomplete view with
these options.

el: The list element which contains list items

collection: The collection to populate the
autocomplete list with.

template:

    listItemTemplate: Template for each list
    item, as a function (Jade)

    locals: A function that takes a model and
    returns a locals object that can be passed
    to the template

getLabel: A function which takes a model, and
returns value that should be returned on item
select for display in input.

matchOn: A function which takes a model, and
returns a value that you want the autocomplete
matcher to match on

handlers:

    itemSelectedHandler: Handler function for
    item select event. Takes a model.

    itemChosenHandler: Handler function for
    item choose event. Takes a model.


## Public Methods

updateTerm(term): Takes a term, filters
collection on term using provided
matchOn(model) method, and updates the list.

unChooseItem(id): Takes a model id, restores
that model to the original collection.

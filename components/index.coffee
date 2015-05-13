# These all use dependency injection to add themselves to various parts of the UI. Things are usually require'd from most specific to least specific so the generic components can discover the specific components through dependency injection.
require './errors'
require './default'
require './front'
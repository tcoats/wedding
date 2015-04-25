{ component, widget } = require 'odojs'
odoql = require 'odoql/plugin'
relay = require 'odo-relay'

component.use odoql
widget.use odoql

require '../components/'
require '../ui/'

Router = require './router'
Router.use relay
body = document.querySelector 'body'
stores = require './stores'
scene = relay body, Router, stores

module.exports = scene
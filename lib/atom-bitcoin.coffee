AtomBitcoinStatusBarView = require './atom-bitcoin-status-bar-view'

module.exports =
  activate: ->
    @atomBitcoinStatusBarView = new AtomBitcoinStatusBarView()

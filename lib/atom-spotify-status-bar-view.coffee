{View} = require 'atom'
jQuery = require 'jquery'

module.exports =
class AtomBitcoinStatusBarView extends View
  @content: ->
    @div class: 'inline-block', =>
      @span outlet: "bitcoinInfo", class: 'atom-bitcoin-status', tabindex: '-1', ""

  initialize: ->
    # We wait until all the other packages have been loaded,
    # so all the other status bar views have been attached
    @subscribe atom.packages.once 'activated', =>
      # We use an ugly setTimeout here to make sure our view gets
      # added as the "last" (farthest right) item in the
      # left side of the status bar
      setTimeout =>
        atom.workspaceView.statusBar.appendLeft(this)
      , 1

  afterAttach: ->
    output_text = ""
    setInterval =>
      jQuery ($) ->
        json = $.getJSON "https://api.bitcoinaverage.com/all", '', (data, resp) ->
          if resp = "success"
            output_text = data['USD']['averages']['last']
          else
            #Handle failed response?
      @bitcoinInfo.text("$#{parseFloat(output_text).toFixed(2)}")
    , 1000

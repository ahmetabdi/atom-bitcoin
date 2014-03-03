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
    output = undefined
    last_output = undefined
    setInterval =>
      jQuery ($) ->
        json = $.getJSON "https://api.bitcoinaverage.com/ticker/USD/last", '', (data, resp) ->
          if resp = "success"
            output = parseFloat(data).toFixed(2)
            if output < last_output
              $(".atom-bitcoin-status").css "color", "green"
              console.log("Going up #{output} - #{last_output}")
            else if output > last_output
              $(".atom-bitcoin-status").css "color", "red"
              console.log("Going down #{output} - #{last_output}")
            else
              $(".atom-bitcoin-status").css "color", "white"
              console.log("Natural? #{output} - #{last_output}")
          else
            #Handle failed response?

      @bitcoinInfo.text("$#{output}")
      last_output = output

    , 10000

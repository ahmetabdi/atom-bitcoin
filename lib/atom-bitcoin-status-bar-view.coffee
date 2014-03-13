{View} = require 'atom'
jQuery = require 'jquery'

module.exports =
class AtomBitcoinStatusBarView extends View
  default_interval: 5000
  load_text: 'Retreiving price...'

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
    # Get user settings for interval
    # Insure it's a number then convert to milliseconds or use default
    interval = atom.config.get('atom-bitcoin.interval')
    interval = if not isNaN(interval) then (interval.toFixed() * 1000) else @default_interval

    # Display loading text
    @display(null)

    output = undefined
    last_output = undefined
    setInterval =>
      jQuery ($) ->
        json = $.getJSON "https://api.bitcoinaverage.com/ticker/USD/last", '', (data, resp) ->
          if resp = "success"
            output = parseFloat(data).toFixed(2)
            if output > last_output
              $(".atom-bitcoin-status").css "color", "green"
            else if output < last_output
              $(".atom-bitcoin-status").css "color", "red"
            else

          else
            #Handle failed response?

      # Update price
      @display(output)
      last_output = output

    , interval # config or default interval


  display: (price) ->
    # Display loading text or current price
    @bitcoinInfo.text(if not price then @load_text else "$#{price}")

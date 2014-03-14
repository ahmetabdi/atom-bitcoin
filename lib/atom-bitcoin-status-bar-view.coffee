{View} = require 'atom'
jQuery = require 'jquery'
valid_currencies = require './currencies'

module.exports =
class AtomBitcoinStatusBarView extends View
  default_interval: 5000
  default_currency: 'USD'
  load_text: 'Retreiving price...'

  @content: ->
    @div class: 'inline-block atom-bitcoin', =>
      @span outlet: "bitcoinInfo", tabindex: '-1', ""

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

    # Get user settings for currency
    # Insure currency is in the supported list or use default
    currency = atom.config.get('atom-bitcoin.currency')
    currency = if currency of valid_currencies then currency else @default_currency

    # Display loading text
    @display(null)

    output = undefined
    last_output = undefined
    setInterval =>
      jQuery ($) ->
        json = $.getJSON 'https://api.bitcoinaverage.com/ticker/'+currency+'/last', '', (data, resp) ->
          if resp = "success"
            output = parseFloat(data).toFixed(2)
          else
            #Handle failed response?

      # Set color for ticker
      @bitcoinInfo.removeClass('status-stable status-rise status-fall')
      if output > last_output
        @bitcoinInfo.addClass('status-rise')
      else if output < last_output
        @bitcoinInfo.addClass('status-fall')
      else
        @bitcoinInfo.addClass('status-stable')

      # Update price
      @display(output, valid_currencies[currency])
      last_output = output

    , interval # config or default interval


  display: (price, symbol) ->
    # Display loading text or current price
    @bitcoinInfo.text(if not price then @load_text else symbol+price)

# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on "turbolinks:load",  ->
  # console.log "loaded in memory"
  # subscription =
  #   setupForm: ->
  #     $(document).on 'submit','#new_subscription', (e) ->
  #       $('input[type=submit]').attr('disabled', true)
  #       console.log "card_number length",$('#card_number').length
  #       if $('#card_number').length
  #         console.log "in if"
  #         subscription.processCard()
  #         false
  #       else
  #         console.log "in else"
  #         true

  #   processCard: ->
  #     card =
  #       number: $('#card_number').val()
  #       cvc: $('#card_code').val()
  #       expMonth: $('#card_month').val()
  #       expYear: $('#card_year').val()
  #     Stripe.createToken(card, subscription.handleStripeResponse)

  #   handleStripeResponse: (status, response) ->
  #     if status == 200
  #       $('#subscription_stripe_card_token').val(response.id)
  #       $('#new_subscription')[0].submit()
  #     else
  #       $('#stripe_error').text(response.error.message)
  #       $('input[type=submit]').attr('disabled', false)
subscription =
  processCard: ->
    card =
      number: $('#card_number').val()
      cvc: $('#card_code').val()
      expMonth: $('#card_month').val()
      expYear: $('#card_year').val()
    console.log "card",card
    Stripe.createToken(card, subscription.handleStripeResponse)

  handleStripeResponse: (status, response) ->
    if status == 200
      $('#subscription_stripe_card_token').val(response.id)
      submit_order(response.id)
      # $('#new_subscription')[0].submit()
    else
      $('#stripe_error').text(response.error.message)
      $('#proceed_to_payment').attr('disabled', false)

$(document).on 'submit','#new_subscription', (e) ->
  Stripe.setPublishableKey("sk_test_FWynkqBvqM82xZvrO73iUbsx")
  # Stripe.setPublishableKey("pk_live_i7mCpa8KuihrJh2msCmXTkPT")
  $('#proceed_to_payment').attr('disabled', true)
  console.log "card_number length",$('#card_number').length
  if $('#card_number').length
    subscription.processCard()
    false
  else
    true


jQuery ->
  # we incorporate the if cond here as we wont get stripe undefiend in index page
  if $("#stripe_error").length
    Stripe.setPublishableKey($('meta[name="stripe-key"]').attr('content'))
    subscription.setupForm()

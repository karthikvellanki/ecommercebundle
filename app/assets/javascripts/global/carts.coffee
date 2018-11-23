# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).on "turbolinks:load",  ->
  $('.carousel').carousel()
$(document).on "turbolinks:load",  ->
  $('.dropdown').hover (->
    $('.dropdown-menu', this).not('.in .dropdown-menu').stop(true, true).slideDown '400'
    $(this).toggleClass 'open'
    return
  ), ->
    $('.dropdown-menu', this).not('.in .dropdown-menu').stop(true, true).slideUp '400'
    $(this).toggleClass 'open'
    return
  return
# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

window.get_cart_items = () ->
	'use strict'
	$.ajax $('#cart_id_for_ajax').val() + '/get_cart_items.json',
		type: 'GET'
		dataType: 'text'
		success: (data, jqxhr, textStatus) ->
			$('#cart_items').html data
		error: (jqxhr, textStatus, errorThrown) ->
			alert 'Could not update cart items'

window.get_cart_dropdown = () ->
	cart_id = $('#cart_id_for_ajax').val()
	$.ajax '/carts/' + cart_id + '.json',
		type: 'GET',
		dataType: 'text'
		data: {
			type: 'dropdown'
		}
		success: (data, jqxhr, textStatus) ->
			$('#dropdown_cart').html data
		error: (jqxhr, textStatus, errorThrown) ->
			$('#dropdown_cart').html 'Could not load your cart'


window.get_small_cart = () ->
	cart_id = $('#cart_id_for_ajax').val()
	$.get cart_id + '/get_small_cart.json', (data) ->
		$('#small_cart').html data
	$.ajax cart_id + '/get_small_cart.json',
		type: 'GET'
		dataType: 'text'
		success: (data, jqxhr, textStatus) ->
			$('#small_cart').html data
		error: (jqxhr, textStatus, errorThrown) ->

$(document).on 'turbolinks:load', ->
	cart_id = $('#cart_id_for_ajax').val()
	if cart_id > 0
		window.location.hash = 'cart'
		$('#carts-tab').addClass('active')

$(window).on 'hashchange', ->
	cart_id = $('#cart_id_for_ajax').val()
	if cart_id > 0
		hash = window.location.hash
		switch hash
			when '#cart'
				$('#carts-tab').addClass('active')
				$('#shipping-tab').removeClass('active')
				$('.checkout-steps li:nth-child(1)').removeClass('active').removeClass('done')
				$('.checkout-steps li:nth-child(2)').removeClass('active')
			when '#shipping'
				$('#carts-tab').removeClass('active')
				$('#shipping-tab').addClass('active')
				$('#payment-tab').removeClass('active')
				$('#proceed_to_payment').prop('disabled', false)
				$('.checkout-steps li:nth-child(1)').removeClass('active').addClass('done')
				$('.checkout-steps li:nth-child(2)').addClass('active')
			when '#payment'
				$('#shipping-tab').removeClass('active')
				$('#payment-tab').addClass('active')
				$('#carts-tab').removeClass('active')
				$('.checkout-steps li:nth-child(2)').removeClass('active').addClass('done')
				$('.checkout-steps li:nth-child(3)').addClass('active')
			else
				location.reload()

$(document).on 'keypress', '#cart_signin_form',(event) ->
		if event.keyCode is 13
			event.preventDefault()
			if $('#continue_as_guest').length is 0
				check_email()


window.clear_address = () ->
  $('#new_order input[name="city"]').val("").prop('disabled', false)
  $('#new_order input[name="state"]').val("").prop('disabled', false)
  $('#new_order input[name="pincode"]').val("").prop('disabled', false)
  $('#new_order input[name="line_1"]').val("").prop('disabled', false)
  $('#new_order input[name="line_2"]').val("").prop('disabled', false)
  $('#new_order input[name="line_3"]').val("").prop('disabled', false)
  $('#new_order input[name="first_name"]').val("").prop('disabled', false)
  $('#new_order input[name="last_name"]').val("").prop('disabled', false)
  $('#new_order input[name="mobile_number"]').val("").prop('disabled', false)
  $('#new_order input[name="email"]').val("").prop('disabled', false)
  $('#new_order input[name="old_address_id"]').val("").prop('disabled', false)

window.select_card = (card_id) ->
  card = $('#card-data-'+card_id).data('card')
  $("#last4").text card.last4;
  $("#exp").text card.exp_month + "/" + card.exp_year;
  $("#stripe_token").val(card.stripe_customer_token);

window.select_address = (address_id) ->
  address = $('#address-data-'+address_id).data('address')
  $('#new_order input[name="city"]').val(address.city).prop('disabled', true)
  $('#new_order input[name="state"]').val(address.state).prop('disabled', true)
  $('#new_order input[name="pincode"]').val(address.pincode).prop('disabled', true)
  $('#new_order input[name="line_1"]').val(address.line_1).prop('disabled', true)
  $('#new_order input[name="line_2"]').val(address.line_2).prop('disabled', true)
  $('#new_order input[name="line_3"]').val(address.line_3).prop('disabled', true)
  #$('#new_order input[name="first_name"]').val(address.first_name).prop('disabled', true)
  #$('#new_order input[name="last_name"]').val(address.last_name).prop('disabled', true)
  #$('#new_order input[name="mobile_number"]').val(address.mobile_number).prop('disabled', true)
  #$('#new_order input[name="email"]').val(address.email).prop('disabled', true)
  $('#new_order input[name="old_address_id"]').val(address.id).prop('disabled', true)

# window.submit_payment_details = (order_id) ->
#   $.ajax '/orders/'+order_id+'/save_payment_details',
#     type: 'PATCH'
#     data: params
#     dataType: 'text'
#     success: (data, jqxhr, textStatus) ->
#       window.location.href = "/orders/"+data
#     error: (jqxhr, textStatus, errorThrown) ->
#       console.log("Payment errors")
window.submit_order = (payment_method,stripe_token,card) ->
  user_is_invoice = $('#user_is_invoice').val()
  params =
    city: $('#new_order input[name="city"]').val()
    state: $('#new_order input[name="state"]').val()
    pincode: $('#new_order input[name="pincode"]').val()
    line_1: $('#new_order input[name="line_1"]').val()
    line_2: $('#new_order input[name="line_2"]').val()
    line_3: $('#new_order input[name="line_3"]').val()
    first_name: $('#new_order input[name="first_name"]').val()
    last_name: $('#new_order input[name="last_name"]').val()
    cart_id: $('#cart_id_for_ajax').val()
    mobile_number: $('#new_order input[name="mobile_number"]').val()
    email: $('#new_order input[name="email"]').val()
    address_type: $('#new_order input[name="address_type"]').val()
    cart_id: $('#new_order input[name="cart_id"]').val()
    old_address_id: $('#new_order input[name="old_address_id"]').val()
  amount = parseInt($('#new_order input[name="total_cents"]').val())
  error = []
  errorText = ''
  for key of params
    if key == 'line_3' || key == 'line_2' || key == 'old_address_id'
      continue
    else if params[key] is ''
      errorText = key + ' is blank<br>'
      console.log $('#new_order input[name="' + key + '"]')
      $('#new_order input[name="' + key + '"]').next().empty().append(errorText)
    if key is 'mobile_number' && params[key].length isnt 10
      errorText = 'Mobile number should be 10 digits<br>'
      $('#new_order input[name="' + key + '"]').next().empty().append(errorText)
    # if key is 'mobile_number' && isNaN(parseInt(params[key]))
    #   errorText = 'Mobile number must not contain alphabets or symbols<br>'
    #   $('#new_order input[name="' + key + '"]').next().empty().append(errorText)
    if key is 'pincode' && params[key].length isnt 5
      errorText = 'Zip Code can be of only 5 characters<br>'
      $('#new_order input[name="' + key + '"]').next().empty().append(errorText)
    if key is 'line_1' && params[key].length > 36
      errorText = 'line 1 can be of only 36 characters<br>'
      $('#new_order input[name="' + key + '"]').next().empty().append(errorText)
    if key is 'line_2' && params[key].length > 36
      errorText = 'line 2 can be of only 36 characters<br>'
      $('#new_order input[name="' + key + '"]').next().empty().append(errorText)
    if key is 'line_3' && params[key].length > 36
      errorText = 'line can be of only 36 characters<br>'
      $('#new_order input[name="' + key + '"]').next().empty().append(errorText)
  if errorText.length is 0
    # params["payment_method"] = payment_method
    # if payment_method == "card"
    #   params["stripeToken"] = stripe_token
    #   if typeof(card) != "undefined" && card.last4 != null && stripe_token != null
    #     params["last4"] = card.last4
    #     params["exp_month"] = card.exp_month
    #     params["exp_year"] = card.exp_year
    $.ajax '/orders',
      type: 'POST'
      data: params
      dataType: 'text'
      success: (data, jqxhr, textStatus) ->
        if(data.length > 0)
          if user_is_invoice == "true"
          	window.location.href = "/orders/"+data
          else
          	window.location.href = "/orders/"+data+"/payments"
      error: (jqxhr, textStatus, errorThrown) ->
        $('#proceed_to_payment').html("Make Payment").attr('disabled', false)
        $('#cart_pay_with_bank').html("Pay using Bank").attr('disabled', false)
        swal '', 'Something went wrong. Your order was not created', 'error'
  else
    $('#proceed_to_payment').html("Make Payment").attr('disabled', false)
    $('#cart_pay_with_bank').html("Pay using Bank").attr('disabled', false)
    swal '', 'Please check your errors', 'error'
  return false


$(document).on 'change', '.cart_item_quantity', ->
	cart_item_id = $(this).data('cart-item-id')
	current_value = parseInt $('#cart_item_quantity_box_' + cart_item_id).val()
	cart_item =
		quantity: current_value
	$.ajax '/cart_items/' + cart_item_id,
		type: 'PATCH'
		dataType: 'text'
		data: {
			cart_item: cart_item
		}
		success: (data, jqxhr, textStatus) ->
			get_cart_dropdown()
			get_cart_items()
			get_small_cart()
		error: (jqxhr, textStatus, errorThrown)->
			$.jGrowl 'Could not update quantity', life: 3000

$(document).on 'click', '.remove_cart_item', ->
	cart_item_id = $(this).data('cart_item_id')
	$.ajax '/cart_items/' + cart_item_id + '.json',
		type: 'DELETE'
		dataType: 'text'
		success:(data, jqxhr, textStatus) ->
			get_cart_items()
			get_cart_dropdown()
			get_small_cart()
		error: (jqxhr, textStatus, errorThrown) ->
			$.jGrowl 'Could not remove cart item', life: 3000

$(document).on 'click', '#confirm_cart', ->
  window.location.hash = 'shipping'
  $('#shipping_bar').addClass('active')

window.check_email = () ->
	email = $('#cart_signin_email').val()
	if email != ''
		$.ajax '/users/check_user',
			data: {
				user:{
					email: email
				}
			}
			type: 'GET',
			success: (data, jqxhr, textStatus) ->
				$('#cart_check_email_button').remove()
				$('#cart_signin #continue_as_guest').remove()
				$('#cart_signin #forgot_password').remove()
				$('#relationship').empty()
				$('#relationship').html '<h5> <span><h2 class="font-architect">You already have an account with us!</h2></span></h5>'
				$('#cart_signin_form').append('<div class="input-group wide250">
                                        <span id="basic-addon2" class="input-group-addon">
                                          <i class="fa fa-lock fa-lg"></i>
                                        </span>
                                        <input class="form-control" aria-describedby="basic-addon2" name="user[password]" placeholder="Password" type="password"></input>
                                      </div>')
				$('#cart_signin_form').append('<div class="text-center"><button class="btn btnpink width300 mt10" id="cart_signin_button"> Sign In </button></div>' )
				$('#cart_signin').append('<div class="text-center mt10"><button class="btn width300 btnpink" id="continue_as_guest"> Continue as Guest </button></div><br>' )
				$('#cart_signin').append('<div class="text-center"><a id="forgot_password" class="dec margin_top vertical-align" href="#{new_password_path(resource_name)}"> Forgot Password? </a></div>' )
				$('#new_order input[name="email"]').val(email)
				$('#shipping_bar').addClass('active')
			error: (jqxhr, textStatus, errorThrown) ->
				$('#relationship').empty()
				$('#relationship').html '<h5> <span><h2 class="font-architect">Already have an account with us? <a class="decorate_none" href="#">Log in</a></h2></span></h5>'
				$('#cart_signin #cart_check_email_button').remove()
				$('#cart_signin #continue_as_guest').remove()
				$('#cart_signin').append('<div class="text-center"><button class="btn width300 btn-primary margin_top" id="continue_as_guest"> Continue as Guest </button></div>' )
				$('#new_order input[name="email"]').val(email)
				$('#shipping_bar').addClass('active')
$(document).on 'click', '#cart_check_email_button', ->
	check_email()
$(document).on 'click', '#continue_as_guest', ->
	$('#cart_signin').addClass('hidden')
	$('#shipping_details').removeClass('hidden')

$(document).on 'click', '.tab-1-next', ->
	window.location.hash = 'shipping'

$(document).on 'click', '.tab-1-change-address', ->
	window.location.hash = 'shipping'

$(document).on 'click', '.tab-1-back', ->
	window.location.hash = 'cart'




$(document).on 'blur', '#input_phone_no', ->
	value = $(input_phone_no).val()
	if value.length != 10
		$('#phone_alert').text('Phone no should be 10 numbers.')
	else
		$('#phone_alert').text('')
$(document).on 'blur', '#input_pin_code', ->
	value = $(input_pin_code).val()
	if value.length != 5
		$('#pin_alert').text('Pin code should be 5 numbers.')
	else
		$('#pin_alert').text('')
$(document).on 'blur', '#input_address', ->
			value = $(input_address).val()
			if value.length == 0
				$('#address_alert').text('Address should not be empty')
			else
				$('#address_alert').text('')
$(document).on 'blur', '#input_city', ->
					value = $(input_city).val()
					if value.length == 0
						$('#city_alert').text('City should not be empty')
					else
						$('#city_alert').text('')
$(document).on 'blur', '#input_state', ->
							value = $(input_state).val()
							if value.length == 0
								$('#state_alert').text('State should not be empty')
							else
								$('#state_alert').text('')
$(document).on 'focus', '#input_pin_code', ->
	value = $(input_pin_code).val()
	if value.length == 0
		$('#pin_alert').text('Pin code should not be empty')


# $(document).on 'keyup', '#input_phone_no', (evt) ->
# 	mobile_number = $('#input_phone_no').val().length
# 	if mobile_number > 10
# 	  return false
# 	true

# validateNumber = (evt) ->
#   charCode = if evt.which then evt.which else event.keyCode
#   if charCode > 31 and (charCode < 46 or charCode > 57)
#     return false
#   true

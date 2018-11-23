# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).on 'click touchstart', '#contact_submit_button', (e) ->
  e.preventDefault()
  name = $('#name').val()
  email = $('#email').val()
  message = $('#message').val()
  $.ajax '/send_message',
    type: 'POST'
    data:
      name: name
      email: email
      message: message
    error: (jqXHR, textStatus, errorThrown) ->
      swal 'Message not sent!', 'Please check your Email', 'error'
    success: (data, textStatus, errorThrown) ->
      swal 'Message sent!', 'We will get back to you soon.', 'success'

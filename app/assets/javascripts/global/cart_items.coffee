# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'click', '.delete_cart_item', () ->
  cart_item_id = $(this).data('id')
  $.ajax '/cart_items/'+cart_item_id+'.html',
    type: 'DELETE'
    success:(data) ->
      $('#cart_item_partial').html data
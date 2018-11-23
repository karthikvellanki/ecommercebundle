# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
request_get_name = (page) ->
  if typeof page == undefined
    page = 1
  $.ajax 'dashboard/request_quotes',
    type: 'GET'
    data: {
      page: page
      template: false
    }
    success: (data, jqxhr, textStatus) ->
      $('#request-pge').html data

$(document).on 'change', '#dropdown_pagination', ()->
  page = $(this).val()
  $ -> request_get_name(page)

$(document).on 'click', '#request_pagination_next_page', ()->
  current_page = parseInt $('#request_current_page').data('page')
  $ -> request_get_name(current_page+1)

$(document).on 'click', '#request_pagination_previous_page', ()->
  current_page = parseInt $('#request_current_page').data('page')
  $ -> request_get_name(current_page-1) 



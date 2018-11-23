# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'change', '.supplier-product-image', () ->
	id = $(this).data("id")
	$('#edit_product_'+id).submit()

$(document).on 'click', '.image-upload-button', () ->
	id = $(this).data("id")
	$('input[name=image-upload-'+id+']').click()

$(document).on 'click', '.update-product-image', () ->
	id = $(this).data("id")
	$('input[name=image-upload-'+id+']').click()

$(document).on 'click', '#delete-multiple-products', () ->
  product_ids = []
  $('input.delete-checkbox:checked').each (index, checkbox) ->
    product_ids.push $(checkbox).val()
    return
  $('#product_ids').val product_ids
  return

$(document).on 'click', ".change-product-status", () ->
	id=$(this).data("id")
	$.ajax '/admin/products/'+id+'/change_storefront_option',
		type:"PATCH"
		success:(data) ->
			$('#product-'+id).html data

$(document).on 'click', "#start_date", () ->
	start_date=$(this).val()
	$.ajax '/admin/orders.html',
		type:"GET"
		data:{
			start_date: start_date,
			template: false
		}
		success:(data) ->
			alert("success")
$(document).on 'click', "#end_date", () ->
	end_date=$(this).val()
	$.ajax '/admin/orders.html',
		type:"GET"
		data:{
			end_date: end_date,
			template: false
		}
		success:(data) ->
			alert("success")

$(document).on 'change', '#store_option_filter', () ->
  type = $(this).val()
  $.ajax '/admin/products',
    type: 'GET'
    data:{
        store_option_type: type,
        template: false
    }
    success:(data) ->
      $('#products_table tbody').html data			


$(document).on 'change', "#category_type_filter", () ->
	category= $(this).val()
	$.ajax '/admin/products.html',
		type: 'GET'
		data: {
			product_type_filter: category,
			template: false
		}
		success:(data) ->
			$('#products_table tbody').html data

$(document).on 'keyup', '#product_search', () ->
	search_term = $(this).val()
	$.ajax '/admin/products',
		type: 'GET'
		data: {
			search: search_term,
			template: false
		}
		success:(data, jqxhr, textStatus) ->
			$('#products_table tbody').html data
		error:(jqxhr, textStatus, errorThrown) ->
			$.jGrowl 'Something went wrong.', life:2000

sticky_relocate = ->
		window_top = $(window).scrollTop()
		div_top = $('#sticky-anchor').offset().top
		if window_top > div_top
			$('#sticky').addClass 'stick'
			$('#sticky-anchor').height $('#sticky').outerHeight()
		else
			$('#sticky').removeClass 'stick'
			$('#sticky-anchor').height 0
		return



# $(document).on 'turbolinks:load', () ->
#   $(window).scroll sticky_relocate
#   sticky_relocate()
#   return


$(document).on "turbolinks:load", ->
  $('#owl-demo').owlCarousel
    navigation: false
    slideSpeed: 300
    paginationSpeed: 400
    singleItem: true
  return

$(document).on 'turbolinks:load', ->
    $('.datepicker').datetimepicker(
        format: "YYYY-MM-DD HH:mm"
        );
  	return


# $('input[name=image-upload-33]').change ->
#   alert "sdfsdfsd"
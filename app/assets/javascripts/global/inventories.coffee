$(document).on 'keyup', '#inventory_search', () ->
	search_term = $(this).val()
	$.ajax '/dashboard/products.html',
		type: 'GET'
		data: {
			q: search_term,
			template: false
		}
		success:(data, jqxhr, textStatus) ->
			$('#inventories_table tbody').html data
		error:(jqxhr, textStatus, errorThrown) ->
			$.jGrowl 'Something went wrong.', life:2000



$(document).on 'click', '.get-values', () ->
	$.ajax '/dashboard/products',
		type: 'POST'
		data: {
			all_data: all_data
		}
		dataType: 'text'
		success: (data, textStatus, jqXHR) ->
      console.log "success"
	return false
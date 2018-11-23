# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).on 'keyup', '#customer_catalog', () ->
  user_id = $(this).data('id')
  search_term = $(this).val()
  $.ajax '/admin/users/'+ user_id+'/catalog',
    type: 'GET'
    data: {
      search: search_term,
      template: false
    }
    success:(data, jqxhr, textStatus) ->
      $('#users_table tbody').html data

$(document).on 'keyup', '#users_search', () ->
	search_term = $(this).val()
	$.ajax '/admin/users.html',
		type: 'GET'
		data: {
			search: search_term,
			template: false
		}
		success:(data, jqxhr, textStatus) ->
			$('#users_table tbody').html data
		error:(jqxhr, textStatus, errorThrown) ->
			$.jGrowl 'Something went wrong.', life:2000


$(document).on 'keyup', '#orders_search', () ->
	search_term = $(this).val()
	$.ajax '/admin/orders.html',
		type: 'GET'
		data: {
			search: search_term,
			template: false
		}
		success:(data, jqxhr, textStatus) ->
			$('#orders_table tbody').html data
		error:(jqxhr, textStatus, errorThrown) ->
			$.jGrowl 'Something went wrong.', life:2000

$(document).on 'click', '#add_address', () ->
	$('.new_address_form').toggleClass('hidden')

$(document).on 'click', '.edit_address', () ->
	id= $(this).data('id')
	$('#edit_address_'+id).toggleClass('hidden')

$(document).on 'turbolinks:load', ->
  $('.navbar_button_text').click ->
    $('#section1').scrolldown(500)
    return
  return



# $(document).on 'turbolinks:load', ->
#   $(document).on 'ajax:success', '.new_address_form', (e, data, status, xhr) ->
#     $ -> get_user_address_section()
#   $(document).on "ajax:error", '.new_address_form', (e, data, status, xhr) ->
#     alert 'Oops, there was an error!'
#    $(document).on 'ajax:success', '.edit_address_form', (e, data, status, xhr) ->
#      $ -> get_user_address_section()
#    $(document).on "ajax:error", '.edit_address_form', (e, data, status, xhr) ->
#      alert 'Oops, there was an error!'
# get_user_address_section = () ->
# 	$.ajax '/users/addresses',
# 		type: 'GET'
# 		success: (data) ->
#       		$.when($('.user_address_section').html data)

$(document).on 'click', '.create-bid', () ->
  id = $(this).data("id")
  bid = $(".input-bid-"+id).val()
  $.ajax '/admin/request_quotes/'+ id + '/create_bid',
    type: 'POST'
    dataType: 'text'
    data: {
      bid: bid
    }
    success: (data,jqXHR, textStatus) ->
      location.reload()

document.addEventListener 'DOMContentLoaded', ->
  if document.getElementById('modalWidth4') != null
    document.getElementById('modalWidth4').onclick = ->
      setTimeout (->
        `var hot4`

        bindDumpButton = ->
          Handsontable.dom.addEvent document.body, 'click', (e) ->
            element = e.target or e.srcElement
            if element.nodeName == 'BUTTON' and element.name == 'dump4'
              name = element.getAttribute('data-dump')
              instance = element.getAttribute('data-instance')
              hot = window[instance]
              $.ajax '/dashboard/request_quotes/create_request_quotes',
                type: 'POST'
                data:{
                		all_data: hot4.getData()
                	}
                dataType: 'text'
                success: (data, textStatus, jqXHR) ->
                  location.reload()
                  return
            return
          return

        data = [ {
          product: ''
          itemNumber: ''
          description: ''
          quantity: ''
        } ]
        container = document.getElementById('example4')
        hot4 = undefined
        hot4 = new Handsontable(container,
          data: data
          startRows: 5
          colHeaders: true
          rowHeaders: true
          minSpareRows: 100
          columns: [
            {
              data: 'product'
              type: 'text'
            }
            {
              data: 'itemNumber'
              renderer: 'text'
            }
            {
              data: 'description'
              type: 'text'
            }
            {
              data: 'quantity'
              type: 'numeric'
            }
          ]
          colWidths: [115,100,120,100]
          manualColumnResize: true
          manualRowResize: true
          manualRowMove: true
          colHeaders: [
            'Product'
            'Item Number'
            'Description'
            'Quantity'
          ])
        bindDumpButton()
        return
      ), 200
      return

    return


document.addEventListener 'DOMContentLoaded', ->
  if document.getElementById('modalWidth5') != null
    $('#create-product-btn').removeClass('hidden');
    $(this).addClass('hidden');
    setTimeout (->
      `var hot5`

      bindDumpButton = ->
        Handsontable.dom.addEvent document.body, 'click', (e) ->
          element = e.target or e.srcElement
          if element.nodeName == 'BUTTON' and element.name == 'dump5'
            name = element.getAttribute('data-dump')
            instance = element.getAttribute('data-instance')
            hot = window[instance]
            $.ajax '/admin/products/products_for_supplier',
              type: 'POST'
              data:{
                  all_data: hot5.getData()
                }
              dataType: 'text'
              success: (data, textStatus, jqXHR) ->
                window.location.href = "/admin/products";
                return
          return
        return

      category_names = $('.category_names').val()
      supplier_category_names = $('.supplier_category_names').val()
      data = [ {
        name: ''
        sku: ''
        price: ''
        category: eval(category_names)[0]
        supplier_category: ''
        cover: ''
        brand: ''
        technical_specification_1: ''
        technical_specification_2: ''
        technical_specification_3: ''
        technical_specification_4: ''
        technical_specification_5: ''
        technical_specification_6: ''
        technical_specification_7: ''
        technical_specification_8: ''
        technical_specification_9: ''
        technical_specification_10: ''
        technical_specification_11: ''
        technical_specification_12: ''
        technical_specification_13: ''
        technical_specification_14: ''
        technical_specification_15: ''
        technical_specification_16: ''
        technical_specification_17: ''
        technical_specification_18: ''
        technical_specification_19: ''
        technical_specification_20: ''
        technical_specification_21: ''
        technical_specification_22: ''
        technical_specification_23: ''
        technical_specification_24: ''
        technical_specification_25: ''
        technical_specification_26: ''
        technical_specification_27: ''
        technical_specification_28: ''
        technical_specification_29: ''
        technical_specification_30: ''
      } ]
      container = document.getElementById('example5')
      hot5 = undefined
      hot5 = new Handsontable(container,
        data: data
        startRows: 5
        colHeaders: true
        rowHeaders: true
        minSpareRows: 100
        columns: [
          {
            data: 'name'
            type: 'text'
          }
          {
            data: 'sku'
            renderer: 'text'
          }
          {
            data: 'price'
            type: 'numeric'
          }
          {
            data: 'category'
            type: 'dropdown'
            source: eval(category_names)
          }
          {
            data: 'supplier_category'
            type: 'dropdown'
            source: eval(supplier_category_names)
          }
          {
            data: "cover"
            renderer: 'text'
          }
          {
            data: "brand"
            type: 'text'
          }
          {
            data: "technical_specification_1"
            type: 'text'
          }
          {
            data: "technical_specification_2"
            type: 'text'
          }
          {
            data: "technical_specification_3"
            type: 'text'
          }
          {
            data: "technical_specification_4"
            type: 'text'
          }
          {
            data: "technical_specification_5"
            type: 'text'
          }
          {
            data: "technical_specification_6"
            type: 'text'
          }
          {
            data: "technical_specification_7"
            type: 'text'
          }
          {
            data: "technical_specification_8"
            type: 'text'
          }
          {
            data: "technical_specification_9"
            type: 'text'
          }
          {
            data: "technical_specification_10"
            type: 'text'
          }
          {
            data: "technical_specification_11"
            type: 'text'
          }
          {
            data: "technical_specification_12"
            type: 'text'
          }
          {
            data: "technical_specification_13"
            type: 'text'
          }
          {
            data: "technical_specification_14"
            type: 'text'
          }
          {
            data: "technical_specification_15"
            type: 'text'
          }
          {
            data: "technical_specification_16"
            type: 'text'
          }
          {
            data: "technical_specification_17"
            type: 'text'
          }
          {
            data: "technical_specification_18"
            type: 'text'
          }
          {
            data: "technical_specification_19"
            type: 'text'
          }
          {
            data: "technical_specification_20"
            type: 'text'
          }
          {
            data: "technical_specification_21"
            type: 'text'
          }
          {
            data: "technical_specification_22"
            type: 'text'
          }
          {
            data: "technical_specification_23"
            type: 'text'
          }
          {
            data: "technical_specification_24"
            type: 'text'
          }
          {
            data: "technical_specification_25"
            type: 'text'
          }
          {
            data: "technical_specification_26"
            type: 'text'
          }
          {
            data: "technical_specification_27"
            type: 'text'
          }
          {
            data: "technical_specification_28"
            type: 'text'
          }
          {
            data: "technical_specification_29"
            type: 'text'
          }
          {
            data: "technical_specification_30"
            type: 'text'
          }
        ]
        colWidths: [95,80,80,100,180,120,80, 190, 190, 190, 190, 190, 190, 190, 190, 190, 190, 190, 190, 190, 190, 190, 190, 190, 190, 190, 190, 190, 190, 190, 190, 190, 190, 190, 190, 190, 190]
        manualColumnResize: true
        manualRowResize: true
        manualRowMove: true
        colHeaders: [
          'Name'
          'SKU'
          'Price'
          'Category'
          'Supplier Category'
          'Product Image'
          'Brand'
          'Technical Specification 1'
          'Technical Specification 2'
          'Technical Specification 3'
          'Technical Specification 4'
          'Technical Specification 5'
          'Technical Specification 6'
          'Technical Specification 7'
          'Technical Specification 8'
          'Technical Specification 9'
          'Technical Specification 10'
          'Technical Specification 11'
          'Technical Specification 12'
          'Technical Specification 13'
          'Technical Specification 14'
          'Technical Specification 15'
          'Technical Specification 16'
          'Technical Specification 17'
          'Technical Specification 18'
          'Technical Specification 19'
          'Technical Specification 20'
          'Technical Specification 21'
          'Technical Specification 22'
          'Technical Specification 23'
          'Technical Specification 24'
          'Technical Specification 25'
          'Technical Specification 26'
          'Technical Specification 27'
          'Technical Specification 28'
          'Technical Specification 29'
          'Technical Specification 30'
        ])

      bindDumpButton()
      return
    ), 200
    return

$(document).on 'change', '#shipping_value', () ->
	shipping_value = $(this).val();
	if shipping_value == "use_my_shipping_account_number"
		$('.shipping_detail').toggleClass('hidden');

$(document).on 'change', '#shipping_value', () ->
	shipping_value = $(this).val();
	if shipping_value == "use_supplier_shipping_method"
		$('.shipping_detail').addClass('hidden');


$(document).on "turbolinks:load", ->
  $('.chosen-select').chosen
    allow_single_deselect: true
    no_results_text: 'No results matched'
    multiple: true
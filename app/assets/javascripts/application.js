// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require sweetalert
//= require trix
//= require trix_attachments
//= require jquery
//= require jquery_ujs
// require dresssed
//= require cocoon
// require local-time
//= require chosen-jquery
//= require app/pay
//= require owl.carousel
//= require moment
//= require bootstrap-datetimepicker
//= require_tree ./global
//= require login-bundle
//= require handsontable.full
//= require select2.min

/* // require turbolinks */
$(document).on  ('ready turbolinks:load', function(){
  if (window.location.pathname === "/categories"){
      $('.hide_on_category').addClass('hidden');
      console.log('hide');
  }
});

$(document).on ('ready turbolinks:load', function(){
  if (window.location.pathname === "/products"){
      $('.hide_on_category').addClass('hidden');
      console.log('hide');
  }


});
$(document).on ('ready turbolinks:load', function(){
  if (window.location.pathname === "/visitors/contact"){
      $('.hide_on_category').addClass('hidden');
      console.log('hide');
  }


});


document.addEventListener("DOMContentLoaded", function() {
// document.addEventListener("TEMPORARY_REMOVE", function() {
  if (document.getElementById('modalWidth') !== null) {
    document.getElementById("modalWidth").onclick = function() {
      setTimeout(function(){
        supplier_names = $('.supplier_names').val()

        var data = [
            {name: '', sku: '', priceInUsd: '0.00',inStock: '0', supplier: eval(supplier_names)[0]}
          ],
          container = document.getElementById('example1'),
          hot1;
        var hot1 = new Handsontable(container, {
          data: data,
          startRows: 5,
          colHeaders: true,
          rowHeaders: true,
          minSpareRows: 100,
          columns: [
            {data: "name", type: 'text'},
            // 'text' is default, you don't actually need to declare it
            {data: "sku", renderer: 'text'},
            // use default 'text' cell type but overwrite its renderer with yellowRenderer
            {data: "priceInUsd", type: 'numeric'},
            {data: "inStock", type: 'numeric'},
            {data: "supplier",
              type: 'dropdown',
              source: eval(supplier_names)
            }
          ],
          colWidths: [80,80,80,80,120],
          manualColumnResize: true,
          manualRowResize: true,
          manualRowMove: true,
          colHeaders: ["Name", "SKU", "Price in USD","In Stock","Supplier"]
        });

    function bindDumpButton() {

      Handsontable.dom.addEvent(document.body, 'click', function (e) {

        var element = e.target || e.srcElement;

        if (element.nodeName == "BUTTON" && element.name == 'dump') {
          var name = element.getAttribute('data-dump');
          var instance = element.getAttribute('data-instance');
          var hot = window[instance];
          $.ajax('/dashboard/products', {
            type: 'POST',
            data: {
              all_data: hot1.getData()
            },
            dataType: 'text',
            success: function(data, textStatus, jqXHR) {
              location.reload();
            }
          });
        }
      });
    }
    bindDumpButton();
      }, 200);
      }
  }
});

$(document).on('click', "#change_invoice", function() {
  var id;
  id = $(this).data("id");
  return $.ajax('/admin/users/' + id + '/change_invoice_status', {
    type: "PATCH",
    data: {
    	id: id,
    },
    success: function(data) {
      location.reload();
    }
  });
});

$(document).ready(function() {
	$("#delete-multiple-pages").click(function() {
	var page_ids = [];
	$('input.delete-checkbox:checked').each(function(index,checkbox) {
		page_ids.push($(checkbox).val());
	}); 
	$("#page_id").val(page_ids);
	});
});

$(document).ready(function() {
	$("#delete-multiple-customer").click(function() {
	var customer_ids = [];
	$('input.delete-checkbox:checked').each(function(index,checkbox) {
		customer_ids.push($(checkbox).val());
	}); 
	$("#customer_id").val(customer_ids);
	});
});

$(document).ready(function() {
	$("#delete-multiple-group").click(function() {
	var group_ids = [];
	$('input.delete-checkbox:checked').each(function(index,checkbox) {
		group_ids.push($(checkbox).val());
	}); 
	$("#group_id").val(group_ids);
	});
});
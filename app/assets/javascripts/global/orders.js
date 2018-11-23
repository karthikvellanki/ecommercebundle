$(document).on('click', "#update_status", function() {
	var order_id = $(this).val();
  var modal = $("#modal-invoice")
  modal.find("#order_id").val(order_id);
  modal.find("form").attr("action","/admin/orders/"+order_id+"/fulfilled/");
  modal.modal("show");
});

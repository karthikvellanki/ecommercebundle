var open_cart_page = function(url,cart_id) {
  var win = window.open(url, '_blank');
  win.focus();
}

function change_cart_item_quantity(cart_item_id,quantity) {
  var data = {cart_item: {quantity: quantity} };
  var workingIcon = $("#loading-"+cart_item_id).show();
  var successFn = function() {
    console.log("Success");
    workingIcon.hide();
    if(quantity <= 0) {
      $("#cart-item-"+cart_item_id).hide(1000);
    }
  };
  var errorFn = function() {
    console.log("Error");
  };
  $.ajax("/cart_items/"+cart_item_id,{method: "PUT", data:data,success: successFn, dataType: "json"}).error(errorFn);
};

$(document).ready(function() {
  $(".quan").on("change",function(e) {
    var input = $(e.target);
    var cart_item_id = input.attr("data-id");
    var quantity = input.val();
    change_cart_item_quantity(cart_item_id,quantity);
  });
});

$(document).ready(function() {
  $(".btn-modal").click(function(e) {
    var button = $(e.target);
    var inventory_id = button.attr("inventory-id");
    var capacity = button.attr("capacity");
    var quantity = button.attr("quantity");
    var threshold = button.attr("threshold");
    var modal = $("#modal-inventory");
    modal.find("#quantity").val(quantity);
    modal.find("#capacity").val(capacity);
    modal.find("#threshold").val(threshold);

    var submitBtn = modal.find("#submit");
    submitBtn.prop("disabled",false);
    submitBtn.html("Save");
    modal.modal("show");
    modal.find("#submit").unbind("click");
    modal.find("#submit").click(function() {
      var data = {};
      data.quantity = modal.find("#quantity").val();
      data.capacity = modal.find("#capacity").val();
      data.threshold = modal.find("#threshold").val();
      submitBtn.prop("disabled",true);
      submitBtn.html("Working...");
      $.ajax("/dashboard/products/"+inventory_id,{data:{inventory:data},dataType: "json",method :"PUT", success:function() {
        console.log("Successfully saved");
        button.parent().parent().first().find("#quantity").html(data.quantity);
        button.parent().parent().first().find("#capacity").html(data.capacity);
        modal.modal("hide");
      }
      ,error:function(response){
        console.log(response);
        submitBtn.prop("disabled",false);
        submitBtn.html("Save");
      }
      });
    });
  });

   $(".price-btn-modal").click(function(e) {
    var button = $(e.target);
    var inventory_id = button.attr("inventory-id");
    var price = button.attr("price");
    var modal = $("#modal-price-inventory");
    modal.find("#price").val(price);
    

    var submitBtn = modal.find("#submit");
    submitBtn.prop("disabled",false);
    submitBtn.html("Save");
    modal.modal("show");
    modal.find("#submit").unbind("click");
    modal.find("#submit").click(function() {
      var data = {};
      data.price = modal.find("#price").val();
      submitBtn.prop("disabled",true);
      submitBtn.html("Working...");
      $.ajax("/dashboard/products/"+inventory_id,{data:{inventory:data},dataType: "json",method :"PUT", success:function() {
        console.log("Successfully saved");
        button.parent().parent().first().find("#price").html(data.price);
        modal.modal("hide");
      }
      ,error:function(response){
        console.log(response);
        submitBtn.prop("disabled",false);
        submitBtn.html("Save");
      }
      });
    });
  });

  $("#delete-multiple-inventories").click(function() {
    var product_ids = [];
    $('input.delete-checkbox:checked').each(function(index,checkbox) {
      product_ids.push($(checkbox).val());
    }); 
    $("#inventory_ids").val(product_ids);
  });

});

function fill_to_par(inventory_id) {
  var div = $("#inventory-"+inventory_id);
  var quantity = parseInt(div.find("#quantity").html());
  var capacity = parseInt(div.find("#capacity").html());
  div.find("#input-quantity").val(capacity>quantity?(capacity-quantity):0);
};

function add_to_cart(inventory_id,product_id) {
  var div = $("#inventory-"+inventory_id);
  var quantity = div.find("#input-quantity").val();
  var data = {quantity: quantity,
              product_id: product_id};
  var cartBtn = div.find("#add_to_cart");
  var workingIcon = cartBtn.find("#icon-working").show();
  var okIcon = cartBtn.find("#icon-ok").hide();
  var successFn = function(data) {
    console.log("Success");
    okIcon.show();
    workingIcon.hide();
    cartBtn.addClass("btn-success");
    $('#cart_partial').html(data)
    /*
    setInterval(function() {
      cartBtn.removeClass("btn-success");
      okIcon.hide();
    },3000);
    */
  };
  var errorFn = function() {
    console.log("Error");
  };
  $.post("/cart_items",data,successFn, "text").error(errorFn);
};
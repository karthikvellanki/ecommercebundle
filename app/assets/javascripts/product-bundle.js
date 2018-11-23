function add_to_cart(product_id) {
  if(!user_id) {
    // show_signup_modal(product_id,true);
    // show_login_modal();
    // return;
    var div = $("#product-"+product_id);
	  var quantity = div.find("#input-quantity").val();
	  var data = {quantity: quantity,
	              product_id: product_id};
	  var cartBtn = div.find("#add_to_cart");
	  var workingIcon = cartBtn.find("#icon-working").show();
	  var okIcon = cartBtn.find("#icon-ok").hide();
	  console.log(data)
	  var successFn = function(data) {
	    console.log("Success");
	    okIcon.show();
	    workingIcon.hide();
	    cartBtn.addClass("cart-added");
	  };
	  var errorFn = function() {
	    console.log("Error");
	  };
	  $.post("/cart_items/session_cart_item", data, successFn, "text").error(errorFn);
  }
  var div = $("#product-"+product_id);
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
  };
  var errorFn = function() {
    console.log("Error");
  };
  $.post("/cart_items", data, successFn, "text").error(errorFn);
};

var alert_fields = "Please fill in the required fields";
var alert_email = "Please enter a valid email";
var alert_password = "Password must be atleast 8 characters";
var email_regex = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/i;

function show_login_modal() {
  var modal = $("#modal-login");
  modal.modal("show");
}
function show_signup_modal(product_id,should_add_to_cart) {
  var modal = $("#modal-signup");
  modal.find("#email").val("").show();
  modal.find("#name").val("").parent().show();
  modal.find("#password").val("").show();
  var method = "signup";
  modal.find("#login").click(function() {
    method = "login";
    modal.find("#name").parent().hide();
    return false;
  });

  var submitBtn = modal.find("#submit");
  var alert = modal.find(".alert");
  submitBtn.prop("disabled",false);
  submitBtn.html("Submit");
  modal.find("#submit").unbind("click");
  modal.modal("show");
  modal.find("#submit").click(function() {
    alert.hide();
    var data = {};
    data.email = modal.find("#email").val();
    data.password = modal.find("#password").val();
    var name = modal.find("#name").val().split(" ");
    data.first_name = (name.length == 1) ? name[0] : name.slice(0,name.length-1).join(" ");
    data.last_name = (name.length == 1) ? "" : name[name.length-1];
    if(!email_regex.test(data.email)) {
      alert.html(alert_email).show();
      return;
    }
    if(method == "signup" && data.password.length < 8) {
      alert.html(alert_password).show();
      return;
    }
    console.log(data);
    submitBtn.prop("disabled",true);
    submitBtn.html("Working...");
    var url = "/users/sign_in";
    if(method == "signup") {
      url = "/users"
    }
    $.post(url, {user: data}, function() {
        if(should_add_to_cart)  {
          var errorFn = function() {
            console.log("Error");
          };
          var div = $("#product-"+product_id);
          var quantity = div.find("#input-quantity").val();
          var data = {quantity: quantity,
                product_id: product_id};
          $.post("/cart_items", data, function() {window.location.reload()}, "text").error(errorFn);
        } else {
          window.location.reload();
        }
      }, "json").error(function(error) {
        submitBtn.prop("disabled",false);
        submitBtn.html("Submit");
        console.log(error);
        if(error.responseJSON.email) {
          alert.html("Email is already in use").show();
        } else
          alert.html(error.responseJSON.error).show();
      });
  });
}

function request_quote(product_id) {
  var div = $("#product-"+product_id);
  var alert = div.find(".alert").hide();
  var quantity = div.find("#input-quantity").val();
  var description = div.find("#input-description").val();
  var data = {quantity: quantity,
              description: description,
              product_id: product_id,
              signup: false};
  if(data.quantity == 0) {
    alert.html("Please enter quantity").show();
    return;
  }
  var cartBtn = div.find("#quote-btn");
  var workingIcon = cartBtn.find("#icon-working").show();
  var okIcon = cartBtn.find("#icon-ok").hide();
  var successFn = function() {
    console.log("Success");
    okIcon.show();
    workingIcon.hide();
    cartBtn.removeClass("btn-primary").addClass("btn-success").html("Requested");
  };
  var errorFn = function() {
    console.log("Error");
  };
  if(!user_id) {
    var modal = $("#modal-quote")
    var submitBtn = modal.find("#submit");
    var alert = modal.find(".alert");
    submitBtn.prop("disabled",false);
    submitBtn.html("Submit");
    modal.modal("show");
    workingIcon.hide();
    modal.find("#submit").unbind("click");
    modal.find("#submit").click(function() {
      alert.hide();
      data.email = modal.find("#email").val();
      data.phone = modal.find("#phone").val();
      if(!email_regex.test(data.email)) {
        alert.html(alert_email).show();
        workingIcon.hide();
        return;
      }
      data.signup = true;
      submitBtn.prop("disabled",true);
      submitBtn.html("Working...");
      $.post("/request_quotes", {request_quote: data}, function() {
        modal.modal("hide");
        window.location.href = "/dashboard/request_quotes";
        }, "text").error(errorFn);
    });
  } else {
    $.post("/request_quotes", {request_quote: data}, successFn, "text").error(errorFn);
  }
};

function request_product() {
  var div = $("#product-request");
  var quantity = div.find("#quantity").val();
  var product_name = div.find("#product_name").val();
  var alert = div.find(".alert").hide().removeClass().addClass("alert alert-danger");
  var data = {quantity: quantity,
              product_name: product_name,
              signup: false};
  var submitBtn = div.find("#submit");
  var workingIcon = div.find("#icon-working").show();
  var successFn = function() {
    console.log("Success");
    workingIcon.hide();
    submitBtn.removeClass("btn-primary").addClass("btn-success");
    submitBtn.html("Submit");
    div.find("#email").val("");
    div.find("#phone").val("");
    div.find("#product-name").val("");
    div.find("#quantity").val("");
    alert.removeClass("alert-danger").addClass("alert-success").html('Product requested successfully. You can manage your requests <a href="/dashboard/request_quotes">here</a>').show();
  };
  var errorFn = function() {
    console.log("Error");
  };
  if(!data.product_name || !data.quantity) {
    alert.html(alert_fields).show();
    workingIcon.hide();
    return;
  }
  if(!user_id) {
    data.email = div.find("#email").val();
    data.phone = div.find("#phone").val();
    if(!email_regex.test(data.email)) {
      alert.html(alert_email).show();
      workingIcon.hide();
      return;
    }
    data.signup = true;
    successFn = function() {
      window.location.href = "/dashboard/request_quotes";
    };
  }
  submitBtn.prop("disabled",true);
  submitBtn.html("Working...");
  $.post("/request_quotes", {request_quote: data}, successFn, "text").error(errorFn);
};

$(document).on('click', ".get_product", function() {
  var id;
  id = $(this).data("id");
  provider_id = $(this).data("provider");
  return $.ajax('/products/get_product_details', {
    type: 'GET',
    data: {
      category_id: id,
      provider_id: provider_id
    },
    success: function(data) {
      $('#product_show_render').html(data);
      // $(this).addClass('black');
    }
  });
});

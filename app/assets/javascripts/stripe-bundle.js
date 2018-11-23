//= require sweetalert

var current_order_id = "";
$(document).ready(function() {
  //var stripe = Stripe('pk_live_i7mCpa8KuihrJh2msCmXTkPT');
  var stripe = Stripe('pk_live_i7mCpa8KuihrJh2msCmXTkPT');
  var elements = stripe.elements();

  var style = {
    base: {
      // Add your base input styles here. For example:
      fontSize: '16px',
      lineHeight: '24px'
    }
  };

  var card = elements.create('card',{style:style});

  mount_card_explicit = function() {
    $("#card-element").show();
    $("#card-message").hide();
    $("#stripe_token").val("");
    mount_card_element();
  }

  mount_card_element = function() {
    card.mount('#card-element');
    card.addEventListener('change', function(event) {
      var displayError = document.getElementById('card-errors');
      if (event.error) {
        displayError.textContent = event.error.message;
      } else {
        displayError.textContent = '';
      }
    });
  }


  if($("#card-not-exists").length) {
    mount_card_element();
  }

  // old payments method
  // $('#new_order').on('submit', function(e) {
  //   e.preventDefault();
  //   $('#proceed_to_payment').html("Working...").attr('disabled', true)
  //   if($("#card-div").hasClass("hidden")) {
  //     submit_order("card","");
  //   } else if($("#stripe_token").val()) {
  //     submit_order("card",$("#stripe_token").val());
  //   } else {
  //     stripe.createToken(card).then(function(result) {
  //       $('#cart_pay_with_bank').html("Pay using Bank").attr('disabled', false)
  //       $('#proceed_to_payment').html("Place Order").attr('disabled', false)
  //       if (result.error) {
  //         // Inform the user if there was an error
  //         var errorElement = document.getElementById('card-errors');
  //         errorElement.textContent = result.error.message;
  //       } else {
  //         // Send the token to your server
  //         submit_order("card",result.token.id,result.token.card);
  //       }
  //     });
  //   }
  // });

  $('#new_order').on('submit', function(e) {
    e.preventDefault();
    $('#proceed_to_payment').html("Working...").attr('disabled', true)
    submit_order("card","");
  });

  $('#pay_order_card').on('click', function(e) {
    e.preventDefault();
    $('#pay_order_card').html("Working...").attr('disabled', true)
    if($("#stripe_token").val()) {
      pay_for_order_with_card($("#stripe_token").val());
    } else {
      stripe.createToken(card).then(function(result) {
        $('#pay_order_card').html("Pay now").attr('disabled', false)
        if (result.error) {
          // Inform the user if there was an error
          var errorElement = document.getElementById('card-errors');
          errorElement.textContent = result.error.message;
        } else {
          // Send the token to your server
          pay_for_order_with_card(result.token.id,result.token.card);
        }
      });
    }
  });

  var pay_for_order_with_card = function(stripe_token,card) {
    var params = {}
    params["stripeToken"] = stripe_token
    if(typeof(card) != "undefined" && card.last4 != null && stripe_token != null) {
      params["last4"] = card.last4;
      params["exp_month"] = card.exp_month;
      params["exp_year"] = card.exp_year;
    }
    var order_id = $("#order_id").val()
    $.ajax("/orders/"+order_id+"/pay_with_card",{
      type: 'POST',
      data: params,
      dataType: 'text',
      success: function(data, jqxhr, textStatus) {
        window.location.reload();
      },
      error: function(jqxhr, textStatus, errorThrown) {
        $('#pay_for_order_with_card').html("Pay Now").attr('disabled', false);
        swal('', 'Something went wrong. Your payment was unsuccessful', 'error');
      }
    });
  }


  $('#bank_account').on('submit', function(e) {
    e.preventDefault();
    var form = $("#bank_account");
    var alert = form.find(".alert").hide();
    var routing_number = form.find("#routing_number").val();
    var account_number = form.find("#account_number").val();
    var name = form.find("#name").val();
    var type = form.find("#type").val();
    if(!routing_number || !account_number || !name || !type) {
      alert.html("All fields are mandatory").show();
      return;
    }

    form.find('#submit').html("Working...").attr('disabled', true);

    var data = {
      country: 'us',
      currency: 'usd',
      routing_number: routing_number,
      account_number: account_number,
      account_holder_name: name,
      account_holder_type: type,
    };

      stripe.createToken('bank_account',data).then(function(result) {
        form.find('#submit').html("Submit").attr('disabled', false)
        if (result.error) {
          alert.html(result.error.message).show();
        } else {
          data.stripe_customer_token = result.token.id;
          $.post("/dashboard/users/update_payment",data,function() {
            window.location.reload();
          },"json").error(function() {
            alert.html("An error occurred").show();
          });
        }
      });
  });

  linkHandler = Plaid.create({
    env: 'development',
    // env: 'sandbox',
    clientName: 'OrderBundle',
    key: '059ec707e448737f37de0c3e624d16',
    // key: 'c32b5bd4114d555153aa6b7b7fbb6a',
    product: ['auth'],
    selectAccount: true,
    onSuccess: function(public_token, metadata) {
      // Send the public_token and account ID to your app server.
      console.log('public_token: ' + public_token);
      console.log('account ID: ' + metadata.account_id);
      console.log(metadata);
      var data = {};
      data.public_token = public_token;
      data.account_id = metadata.account_id;
      data.name = metadata.account.name;
      $.post("/dashboard/users/update_payment",data,function() {
          if(current_order_id && current_order_id != "") {
            pay_ajax(current_order_id);
          } else {
            submit_order("bank");
            // submit_payment_details();
          }
        },"json").error(function() {
          alert.html("An error occurred").show();
        });

    },
    onExit: function(err, metadata) {
      // The user exited the Link flow.
      if(current_order_id && current_order_id != "") {
        $("#icon-working-"+current_order_id).hide();
      } else {
        $("#cart_pay_with_bank").html("Pay using Bank").attr("disabled",false);
      }
    },
  });
});

var pay_for_cart = function(order_id, account_exists) {
  if(account_exists) {
    current_order_id = order_id;
    linkHandler.open();
  } else {
    pay_ajax(order_id);
    // submit_order("bank");
  }
  $("#cart_pay_with_bank").html("Working...");
};

var pay_for_order = function(order_id,account_exists) {
  if(account_exists) {
    current_order_id = order_id;
    linkHandler.open();
  } else {
    pay_ajax(order_id);
  }
  $("#icon-working-"+order_id).show();
};

var pay_ajax = function(order_id) {
  var alert = $('.payment_alert').hide();
  $.post("/orders/"+order_id+"/pay",{},function() {
    console.log('Payment success');
    window.location.href = "/orders/"+order_id
  },"json").error(function(error) {
    console.log(error);
    alert.html(error['responseJSON']['error_message']).show();
    $("#cart_pay_with_bank").html('Pay using Bank')
  });
};

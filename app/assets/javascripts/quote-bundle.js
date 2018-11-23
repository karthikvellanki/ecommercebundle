function accept_bid(bid_id,quote_id) {
  var div = $("#bid-"+bid_id);
  var data = {
    bid_id: bid_id,
  };
  var cartBtn = div.find("#accept_bid");
  var workingIcon = cartBtn.find("#icon-working").show();
  var successFn = function() {
    console.log("Success");
    workingIcon.hide();
    cartBtn.addClass("btn-success");
    cartBtn.html("Accepted");
  };
  var errorFn = function() {
    console.log("Error");
  };
  $.post("/dashboard/request_quotes/"+quote_id+"/accept_bid",data,successFn, "text").error(errorFn);
};
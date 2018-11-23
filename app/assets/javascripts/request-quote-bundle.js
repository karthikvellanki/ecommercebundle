$(document).ready(function() {
   $(".btn-modal").click(function(e) {
    var button = $(e.target);
    var quote_id = button.attr("data-id");
    var modal = $("#modal-quote");
    var submitBtn = modal.find("#submit");

    submitBtn.prop("disabled",false);
    submitBtn.html("Submit");
    modal.modal("show");
    modal.find("#submit").unbind("click");
    modal.find("#submit").click(function() {
      var data = {};
      data.product_id = modal.find("#product_id").val();
      submitBtn.prop("disabled",true);
      submitBtn.html("Working...");
      $.post("/admin/request_quotes/"+quote_id+"/create_bid",{request_quote: data},function() {
        window.location.reload();
        console.log("Successfully saved");
      }).
      error(function(response){
        console.log(response);
        submitBtn.prop("disabled",false);
        submitBtn.html("Submit");
      });
    });
  });
});

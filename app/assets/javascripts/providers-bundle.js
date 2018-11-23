$(document).ready(function() {
  $(".btn-modal").click(function(e) {
    var pid = $(e.target).attr("provider-id");
    var provider = $.grep(providers, function(e){ return e.id == pid; })[0];
    var modal = $("#modal");
    modal.find("#username-label").text(provider.name+" username");
    modal.find("#password-label").text(provider.name+" password");
    var alertBox = modal.find("#alert").hide();
    var submitBtn = modal.find("#submit");
    submitBtn.prop("disabled",false);
    if(provider.credential) {
      submitBtn.text("Update Credentials");
      modal.find("#delete").show();
      modal.find("#username").val(provider.credential.username);
      modal.find("#password").val("");
    } else {
      submitBtn.text("Connect Account");
      modal.find("#delete").hide();
      modal.find("#username").val("");
      modal.find("#password").val("");
    }
    modal.modal("show");
    modal.find("#submit").unbind("click");
    modal.find("#submit").click(function() {
	  alertBox.hide();
      var username = modal.find("#username").val();
      var password = modal.find("#password").val();
      var provider_id = provider.id;
      var data = {};
      data.username = username;
      data.password = password;
      data.provider_id = provider_id;
      submitBtn.prop("disabled",true);
      submitBtn.html("Working...");
      $.post("/credentials/",data,function() {
        console.log("Successfully saved");
        location.reload();
      }).error(function(response){
        console.log(response);
        alertBox.html(response.responseJSON.error).show();
        submitBtn.prop("disabled",false);
        submitBtn.html("Submit");
      });
    });
    modal.find("#delete").unbind("click");
    modal.find("#delete").click(function() {
      var url = "/credentials/" + provider.id;
      $.ajax(url,{method:"DELETE",success:function() {
        console.log("Successfully deleted");
        location.reload();
      },error:function() {
        console.log("some error");
      }});
    });
  });
});
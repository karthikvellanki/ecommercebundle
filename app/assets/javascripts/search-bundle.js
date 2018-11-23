function updateURLParameter(url, param, paramVal){
    var newAdditionalURL = "";
    var tempArray = url.split("?");
    var baseURL = tempArray[0];
    var additionalURL = tempArray[1];
    var temp = "";
    if (additionalURL) {
        tempArray = additionalURL.split("&");
        for (var i=0; i<tempArray.length; i++){
            if(tempArray[i].split('=')[0] != param){
                newAdditionalURL += temp + tempArray[i];
                temp = "&";
            }
        }
    }

    var rows_txt = temp + "" + param + "=" + paramVal;
    return baseURL + "?" + newAdditionalURL + rows_txt;
}

jQuery(document).ready(function($) {
  var search = {};
  search.searchForm = $("#search-form");
  search.inputEl = search.searchForm.find(".form-group input");
  search.resultEl = $(".features_items");

  search.onResponse = function(response) {
    search.resultEl.html(response);
  }

  search.query = function() {
    if(search.xhr) 
      search.xhr.abort();
    var query = search.inputEl.val();
    console.log(query);
    window.history.replaceState('', '', updateURLParameter(window.location.href, "q", query));
    search.xhr = $.get("/live_search",search.searchForm.serialize(),search.onResponse,"html"); 
  }

  search.inputEl.on("keyup",search.query);
});

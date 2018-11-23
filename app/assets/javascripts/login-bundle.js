/*
window.onload =function(e) {
	if(typeof(logged_in_user) == "undefined" || !logged_in_user ) {
		localStorage.clear();
	} else if(!localStorage.getItem("token")) {
		jQuery.getJSON("/users/authenticated_user_auth_token",function(response){
			localStorage.setItem("user",JSON.stringify(response.user));
			localStorage.setItem("token",JSON.stringify(response.token));
		});
	}
}
*/

if(typeof($) == "undefined")
  $ = jQuery;

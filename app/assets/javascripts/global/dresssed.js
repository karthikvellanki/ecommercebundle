//= require dresssed/bootstrap
//= require dresssed/sheets
//= require dresssed/header
//= require dresssed/metis_menu
//= require dresssed/flot
//= require dresssed/morris
//= require dresssed/prettify
//= require dresssed/rickshaw
//= require dresssed/slimscroll

//= require generators/data_generator

/* require dresssed/maps */
$(document).ready(function(){
  $('[data-toggle="popover"]').popover({
    container: 'body'
  });

  $('[data-toggle="tooltip"]').tooltip({
    container: 'body'
  });

  // Required for the SideNav dropdown nav-side-menu
  $('.nav-side-menu').metisMenu();

  if(!Modernizr.touch) {
    $('#menu-content').slimScroll({
         height: 'auto'
     });
  } else {
    $('#menu-content').slimScroll({
         destroy: 'true'
     });
  }
});

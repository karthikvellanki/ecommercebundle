var import_product = function(product_id) {
	$.post("/dashboard/products/import",{product_id:product_id},function(){
    var btn = $("button[data-product=product-import-"+product_id+"]");
    btn.removeClass("btn-default").addClass("btn-success");
    btn.find("i").removeClass("glyphicon-plus").addClass("glyphicon-ok");
  });
  return false;
}

module SupplierCategoriesHelper
	def parent_loop(parent, array=[])
    array << parent.name
    return array.reverse.join("/") if parent.parent_id.nil?
    parent_loop(parent.parent, array)
  end
  
  def category_parent_loop(parent, array=[])
    array << parent.parent.try(:name)
    return array.reverse.join(" > ") if parent.parent_id.nil?
    category_parent_loop(parent.parent, array)
	end
end
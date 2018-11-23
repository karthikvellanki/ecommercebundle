module ApplicationHelper

  def app_name
    "Bundle | Industrial Supplies Purchasing Made Easy"
  end

  def provider
    @current_supplier.present? ? @current_supplier : Provider.none
  end
end

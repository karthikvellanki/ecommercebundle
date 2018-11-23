class Inventory < ApplicationRecord
  belongs_to :user
  belongs_to :product
  belongs_to :picture

  monetize :price_cents

  accepts_nested_attributes_for :picture, reject_if: :all_blank, allow_destroy: true

  def as_json(options = { })
    h = super(options)
    h["picture"] = self.picture
    #h = self.product.as_json.merge h
    ci = CollectionInventory.where(inventory: self).first
    if ci.nil?
      h["collection_id"] = -1
    else
      h["collection_id"] = ci.collection.id
      h["collection"] = ci.collection
    end
    if self.product and self.product.amazon_id
      h["amazon_id"] = self.product.amazon_id
    end
    h
  end

  # def price_cents
  #   return self.product.price_cents
  # end

  def update_discounted_price
    self.price = product.price * (100-discount)/100 
  end

  def cart_quantity(user)
    ci = CartItem.where(product: self.product).includes(:cart).where(carts: {user:user}).first
    if ci.nil?
      return 0
    end 
    return ci.quantity
  end

  scope :search, lambda { |query|
    return nil if query.blank?
    where("LOWER(name) LIKE LOWER(?)", "%#{query}%")
  }

  def collection
    ci = CollectionInventory.where(inventory: self).first
    if ci.nil?
      nil
    else
      ci.collection
    end
  end
  
  # def destroy
  #   Inventory.find(params[:inventories]).destroy
  #   flash[:success] = "Product deleted."
  #   redirect_to inventories_path
  # end
end

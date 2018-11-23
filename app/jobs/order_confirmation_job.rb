class OrderConfirmationJob < ApplicationJob
  queue_as :default

  def perform(cart_id,user_id, name, cart_obj)
    user = User.find(user_id)
    from = user.supplier.present? ? user.supplier.user.email : 'info@getthebundle.com'
    client = Postmark::ApiClient.new('3711f6a9-0319-4091-93a1-400b158ad064', http_open_timeout: 15)
    client.deliver_with_template(from: from,
                                 to: user.email,
                                 template_id: 1047264,
                                 template_model: {
                                   name: name,
                                   cart_items: cart_obj,
                                   order_id: cart_id
                                 })
  end
end

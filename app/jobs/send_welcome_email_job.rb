class SendWelcomeEmailJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    from = user.supplier.present? ? user.supplier.user.email : 'info@getthebundle.com'
    client = Postmark::ApiClient.new('7febfd27-3443-4076-ab6a-06978a075b06', http_open_timeout: 15)
    client.deliver_with_template(from: from,
                                 to: user.email,
                                 template_id: 1469341,
                                 template_model: {
                                   name: user.first_name,
			                             username: user.email
                                 })
  end
end

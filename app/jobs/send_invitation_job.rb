class SendInvitationJob < ApplicationJob
  queue_as :default

  def perform(user_id, invitation_url)
    user = User.find(user_id)
    from = user.supplier.present? ? user.supplier.user.email : 'customercare@bundle.com'
    client = Postmark::ApiClient.new('22322016-6b5b-43d5-ba7d-766966ca0779', http_open_timeout: 15)
    client.deliver_with_template(from: from,
                         to: user.email,
                         template_id: 1024021,
                         template_model: {
                           name: user.first_name,
                           invitation_url: invitation_url
                         })
  end
end

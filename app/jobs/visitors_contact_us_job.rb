class VisitorsContactUsJob < ApplicationJob
  queue_as :default

  def perform(from_param, email_param, message_param)
    # Do something later
    from = from_param
    email = email_param
    message = message_param
    client = Postmark::ApiClient.new('3711f6a9-0319-4091-93a1-400b158ad064', http_open_timeout: 15)
    client.deliver_with_template(from: 'hello@orderbundle.com',
                         to: email,
                         template_id: 2973281 ,
                         template_model: {
                           name: from,
                           email: email,
                           message: message
                         })

   client = Postmark::ApiClient.new('3711f6a9-0319-4091-93a1-400b158ad064', http_open_timeout: 15)
   client.deliver_with_template(from: 'hello@orderbundle.com',
                         to: 'hello@orderbundle.com',
                         template_id: 1097261 ,
                         template_model: {
                           name: from,
                           email: email,
                           message: message
                         })

  end

end

 
class CreateUserRequestJob < ApplicationJob
  queue_as :default

  def perform(request_quote_values, user_id)
    request_quote_values.split(',').each_slice(4).to_a.each do |x|
      RequestQuote.create(product_name: x[0],item_number: x[1],description: x[2],quantity: x[3], user_id: user_id) 
    end
  end
end
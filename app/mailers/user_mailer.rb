class UserMailer < ApplicationMailer
  def order_email(order)
    @order = order 
    @user = @order.user
    mail(to: @user.email,from: "orders@orderbundle.com",subject: "New invoice from "+@order.provider.user.company)
  end
end


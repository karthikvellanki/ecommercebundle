class SupplierMailer < ApplicationMailer

  def welcome_email(supplier,client)
    @user = supplier
    @client = client
    @token = @user.generate_reset_pwd_token
    mail(to: @user.email,subject: "Welcome to Bundle")
  end

  def client_connect_email(supplier,client)
    @user = supplier
    @client = client
    mail(to: @user.email,subject: @client.name + " has connected with you on Bundle")
  end

  def order_email(order)
    @order = order
    @supplier = @order.order_items.first.provider
    @client = @order.user
    mail(to: @supplier.user.email,from: "orders@orderbundle.com",subject: "New Order from "+@client.name)
  end

  def user_connect_email(supplier,client)
    @user = supplier
    @client = client
    mail(to: @user.email,subject: @client.name + " has connected with you on Bundle")
  end

  def invite_user_email(supplier,user)
    @user = user
    @supplier = supplier
    from = @supplier.user.present? ? @supplier.user.email : 'info@orderbundle.com'
    @token = @user.generate_reset_pwd_token
    mail(to: @user.email, from: from,subject: "Welcome to Bundle")
  end

  def bid_accepted_email(supplier,user,bid)
    @user = supplier
    @client = user
    @bid = bid
    mail(to: @user.email,subject: @client.name + " has accepted your quote")
  end

end

class ApplicationMailer < ActionMailer::Base
  default from: 'info@orderbundle.com'
  layout 'mailer'

  def user_welcome_email(user, from_quote=false)
    @user = user
    from = @user.supplier.present? ? @user.supplier.user.email : 'info@orderbundle.com'
    @from_quote = from_quote
    if @from_quote
      @token = @user.generate_reset_pwd_token
    end
    mail(to: @user.email,from: from,subject: "Welcome to Bundle")
  end
end

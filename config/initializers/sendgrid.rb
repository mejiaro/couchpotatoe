SendGridClient = SendGrid::Client.new do |c|
  c.api_user = Rails.application.secrets.sendgrid_api_user
  c.api_key = Rails.application.secrets.sendgrid_api_password
end

if Rails.env.production?
  ActionMailer::Base.smtp_settings = {
      :user_name => Rails.application.secrets.sendgrid_api_user
      :password => Rails.application.secrets.sendgrid_api_password,
      :domain => Rails.application.secrets.email_domain,
      :address => 'smtp.sendgrid.net',
      :port => 587,
      :authentication => :plain,
      :enable_starttls_auto => true
  }
end

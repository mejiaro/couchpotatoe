class RequestMailer < ApplicationMailer
  def after_create_user(request)
    @request = request
    mail(to: @request.user.email, subject: "Bestätigung deiner Anfrage | #{ @request.account.public_name }")
  end

  def after_create_account(request)
    @request = request
    mail(to: @request.account.employees.compact.map(&:email), subject: "Neue Anfrage für Inserat #{ @request.rentable_item.number }")
  end

  def after_accepted_user(request)
    @request = request
    mail(to: @request.user.email, subject: "Deine Anfrage für #{ @request.account.public_name } #{ @request.rentable_item.number } wurde akzeptiert")
  end
end

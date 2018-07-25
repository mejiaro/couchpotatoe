class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_locale
  before_action :get_account_domain


  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def after_sign_in_path_for(resource)
    session.delete(:user_account)

    if request_params.present?
      if current_user.requests.pending.find_by_rentable_item_id(request_params[:rentable_item_id])
        flash[:alert] = 'Du hast bereits eine Anfrage für dieses Objekt gestellt.'
      else
        request = current_user.requests.build(request_params)
        request.user_id = current_user.id
        request.state = 'new'
        request.save
        flash[:notice] = 'Deine Anfrage wurde erfolgreich erstellt.'
      end
      session.delete(:request)
      return  requests_path
    elsif session[:redirect_to].present?
      session[:redirect_to]
    else
      root_path
    end
  end
 
  def get_host_without_www(url)
    uri = URI.parse(url)
    uri = URI.parse("http://#{url}") if uri.scheme.nil?
    host = uri.host.downcase
    host.start_with?('www.') ? host[4..-1] : host
  end

  def request_params
    session[:request]
  end

  def get_account_domain
    current_account
  end

  def current_account
    @related_account ||= if request.domain !~ /couchpotatoe/ && request.domain !~ /c9users/
      Account.find_by_website("http://#{request.domain}")
    elsif request.subdomain != 'www'
      Account.find_by_domain(request.subdomain)
    end
  end
  helper_method :current_account

  def ensure_user_data_valid!
    unless current_user.valid?
      flash[:alert] = 'Um Verträge abschließen zu können, bitte deine Daten vervollständigen (Es ist nicht notwendig das Passwort erneut einzugeben).'
      redirect_to controller: :users, action: :edit, id: current_user.id
      return
    end
  end

  def is_manage?
    false
  end
  helper_method :is_manage?
end

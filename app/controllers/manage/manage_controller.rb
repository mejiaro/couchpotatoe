module Manage
  class ManageController < ActionController::Base
    protect_from_forgery with: :exception
    before_filter :set_locale

    before_filter :check_for_account!
    before_filter :grant_access?

    respond_to :html

    layout 'manage'

    def current_account
      @current_account ||= if request.subdomain == 'manage' && current_user
        current_user.default_account
      elsif request.domain !~ /couchpotatoe/ && request.domain !~ /c9users/
        Account.find_by_website("http://#{request.domain}")
      else
        Account.find_by_domain(request.subdomain)
      end 
    end
    helper_method :current_account

    def check_for_account!
      unless current_account
        redirect_to new_account_url
      end
    end

    def authorize_user
      current_user && current_user.assignments.where(account_id: current_account.id).any?
    end

    def current_assignment
      Assignment.where(employee_id: current_user.id, account_id: current_account.id).first
    end
    helper_method :current_assignment

    def set_locale
      I18n.locale = params[:locale] || 'de'
    end

    def grant_access?
      if authorize_user
        session[:user_account] = false
      else
        session[:user_account] = true
        redirect_to root_path
        return
      end
    end
  
  
    def get_host_without_www(url)
      uri = URI.parse(url)
      uri = URI.parse("http://#{url}") if uri.scheme.nil?
      host = uri.host.downcase
      host.start_with?('www.') ? host[4..-1] : host
    end

    def is_manage?
      true
    end
    helper_method :is_manage?
  end
end

class ManageConstraint
  def self.matches?(request)
    if request.host =~ /c9users.io/
      c9_subdomain = request.host.split('.').reverse[3]
      request.class.class_eval do
        define_method :subdomain do
          c9_subdomain
        end
      end
    end
    
    case request.subdomain
    when 'www', '', nil, 'portfolio'
      false
    else
      if request.session[:user_account]
        false
      else
        true
      end
    end
  end
end

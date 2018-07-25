class MergedFailure < Devise::FailureApp
  def redirect_url
    users_login_and_registration_path
  end

  def respond
    if http_auth?
      http_auth
    else
      redirect
    end
  end
end
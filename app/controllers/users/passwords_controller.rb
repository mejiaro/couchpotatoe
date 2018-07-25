class Users::PasswordsController < Devise::PasswordsController
  # GET /resource/password/new
  # def new
  #   super
  # end

  # POST /resource/password
  # def create
  #   super
  # end

  # GET /resource/password/edit?reset_password_token=abcdef
  # def edit
  #   super
  # end

  # PUT /resource/password
  # def update
  #   super
  # end
  def update
    super do |user|
      user.errors.instance_variable_set(:@messages, user.errors.messages.slice(:password, :password_confirmation))
    end
  end


  protected

  def after_resetting_password_path_for(resource)
    users_login_and_registration_path
  end

  def after_sending_reset_password_instructions_path_for(resource_name)
    users_login_and_registration_path
  end
end

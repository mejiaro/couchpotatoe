class UsersController < ApplicationController
  before_filter :authenticate_user!, only: [:edit, :edit_signature, :update_signature, :update]

  def login_and_registration
    @user = User.new
  end

  def edit

  end

  def edit_signature
  end

  def update_signature
    current_user.signature_data = params[:output]
    current_user.save(validate: false)
      if cookies[:autosign_track].present?
        redirect_to request_path(Contract.find(cookies[:autosign_track]).request, autosign: true)
        cookies[:autosign_track] = nil
      else
        redirect_to edit_user_path(current_user)
      end
  end

  def create
    @user = User.new(user_params)
    if @user.save
      sign_in(@user)

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
        redirect_to requests_path
      elsif session[:redirect_to].present?
        redirect_to session[:redirect_to]
      else
        redirect_to rentable_items_path
      end
    else
      @registration_tab = true
      render 'login_and_registration'
    end
  end

  def update
    sanitized_user_params = user_params['password'].blank? ? user_params.except('password', 'password_confirmation') : user_params
    if current_user.update_attributes(sanitized_user_params)
      if cookies[:autosign_track].present?
        redirect_to edit_signature_user_url
      else
        render :edit
      end
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit :anrede, :address, :zip, :city, :firstname,:lastname, :birthdate, :country, :email, :phone, :password, :password_confirmation, :bank_name, :iban, :bic, :bank_account_holder
  end
end

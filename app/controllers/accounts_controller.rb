class AccountsController < ApplicationController
  before_filter :authenticate_but_save!, only: [:create]

  def new
    if session[:account]
      @account = Account.new(session[:account])
    else
      @account = Account.new
    end
  end

  def create
    @account = Account.new(account_params)

    if @account.save
      a = current_user.assignments.build(account: @account)
      a.save!
      redirect_to "http://#{@account.domain}.#{get_host_without_www(root_url)}"
    else
      render :new
    end
  end

  def logo
    @account = Account.find(params[:id])
    if @account.image?
      send_data File.read(@account.image.document.path(:original))
    else
      render nothing: true
    end
  end

  private

  def account_params
    params.require(:account).permit(:domain, :public_name)
  end

  def authenticate_but_save!
    unless current_user
      session[:account] = request_params unless params[:account].blank?
      session[:redirect_to] = new_account_path
      authenticate_user!
    end
  end
end

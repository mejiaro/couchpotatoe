class RequestsController < ApplicationController

  before_filter :authenticate_but_save!
  before_filter :ensure_user_data_valid!, only: [:blank_contract]
  before_filter :fetch_requests, only: [:index, :show]

  PAYPAL_USERNAME = Rails.application.secrets.paypal_username
  PAYPAL_PASSWORD = Rails.application.secrets.paypal_password
  PAYPAL_SIGN = Rails.application.secrets.paypal_sign

  def index
  end

  def show
    @request = @requests.find(params[:id])
  end

  def upload
    @request = current_user.requests.find(params[:id])
    contract = @request.contract
    contract.attachments.build(document: params[:document], document_type: params[:document_type])

    if contract.save
      flash[:notice] = 'Vertrag wurde erfolgreich hochgeladen.'
    else
      flash[:alert] = "Bitte Datei durch Klicken des Buttons 'Choose File' oder 'Browse' vor dem Upload auswählen. Der Vertrag muss als PDF hochgeladen werden."
    end
    redirect_to requests_path
  end

  def update
    @request = current_user.requests.find(params[:id])
    if @request.update_attributes(request_params)
      respond_to do |format|
        format.html { redirect_to requests_path }
        format.js
      end
    else
      render :edit
    end
  end

  def destroy
    @request = current_user.requests.find(params[:id])
    @request.destroy
    redirect_to requests_path
  end

  def pay
    @request = current_user.requests.find(params[:id])
    @rentable_item = RentableItem.find(@request.rentable_item_id)

    request = Paypal::Express::Request.new(
      :username   => PAYPAL_USERNAME,
      :password   => PAYPAL_PASSWORD,
      :signature  => PAYPAL_SIGN
    )

    payment_request = Paypal::Payment::Request.new(
      :currency_code => :EUR,   # if nil, PayPal use USD as default
      :quantity      => 1,      # item quantity
      :amount => @rentable_item.deposit.to_f,
      items: [{quantity: 1, amount: @rentable_item.deposit.to_f, :description   => "Kaution #{ @rentable_item.account.public_name }" }]
    )

    response = request.setup(
      payment_request,
      paypal_request_url(@request.id),
      paypal_request_url(@request.id)
    )
    redirect_to response.redirect_uri
  end

  def paypal
    @request = current_user.requests.find(params[:id])
    @rentable_item = RentableItem.find(@request.rentable_item_id)


    payment_request = Paypal::Payment::Request.new(
      :currency_code => :EUR,   # if nil, PayPal use USD as default
      :quantity      => 1,      # item quantity
      :amount => @rentable_item.deposit.to_f,
      items: [{quantity: 1, amount: @rentable_item.deposit.to_f, :description   => "Kaution #{ @rentable_item.account.public_name }" }]
    )

    request = Paypal::Express::Request.new(
      :username   => PAYPAL_USERNAME,
      :password   => PAYPAL_PASSWORD,
      :signature  => PAYPAL_SIGN
    )

    response = request.checkout!(
      params[:token],
      params[:PayerID],
      payment_request
    )

    if response.payment_info.first.payment_status == 'Completed'
      c = @request.contract
      c.deposit_paid = true
      c.save!
    end

    redirect_to requests_path
  end

  def blank_contract
    send_file (current_user.requests.find(params[:id]).contract.blank_contract.document.path)
  end

  def passport
    send_file (current_user.requests.find(params[:id]).contract.passport.document.path)
  end

  def create
    if current_user.requests.pending.find_by_rentable_item_id(request_params[:rentable_item_id])
      flash[:alert] = 'Du hast bereits eine Anfrage für dieses Objekt gestellt.'
      redirect_to requests_path
    else
      request = current_user.requests.build(request_params)
      request.user_id = current_user.id
      request.save!
      flash[:notice] = 'Deine Anfrage wurde erfolgreich erstellt.'
      redirect_to request_path(request)
    end
  end

  def add_billing_item
    @request = current_user.requests.find(params[:id])
    @request.contract.billing_items << (@billing_item = @request.rentable_item.account.billing_items.contract_monthly.find(params[:billing_item]))
    respond_to do |format|
      format.html { redirect_to requests_path }
      format.js
    end
  end

  def delete_billing_item
    @request = current_user.requests.find(params[:id])
    @billing_item = BillingItem.find_by(id: params[:billing_item])
    @request.contract.contract_billing_items.where(billing_item_id: params[:billing_item]).each(&:destroy)

    respond_to do |format|
      format.html { redirect_to requests_path }
      format.js
    end
  end

 private

  def fetch_requests
    @requests = current_user.requests.pending.order('created_at DESC')
    if current_account
      @requests = @requests.joins(:rentable_item).where('rentable_items.account_id' => current_account.id)
    end
  end
  def request_params
    params.require(:request).permit(:rentable_item_id, :start_date, :end_date, :visit, :message, :enable_voting)
  end

  def authenticate_but_save!
    unless current_user
      session[:request] = request_params unless params[:request].blank?
      authenticate_user!
    end
  end
end

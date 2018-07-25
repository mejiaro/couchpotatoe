class ContractsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_contract, only: [:show, :edit, :update, :destroy]
  before_action :ensure_user_data_valid!, only: [:download, :preview, :autosign]

  # GET /contracts
  # GET /contracts.json
  def index
    @contracts = current_user.contracts.valid
  end

  # GET /contracts/1
  # GET /contracts/1.json
  def show
  end

  def download
    @contract = current_user.contracts.find(params[:id])

    if params[:document_type] == 'blank_contract'
      attachment = @contract.blank_contract
    elsif params[:document_type] == 'signed_contract'
      attachment = @contract.signed_contract(true)
    end
    send_file attachment.document.path
  end

  # GET /contracts/new
  def new
    @contract = Contract.new
  end

  # GET /contracts/1/edit
  def edit
  end

  # POST /contracts
  # POST /contracts.json
  def create
    @contract = Contract.new(contract_params)

    respond_to do |format|
      if @contract.save
        format.html { redirect_to @contract, notice: 'Contract was successfully created.' }
        format.json { render :show, status: :created, location: @contract }
      else
        format.html { render :new }
        format.json { render json: @contract.errors, status: :unprocessable_entity }
      end
    end
  end

  def preview
    @contract = current_user.contracts.find(params[:id])
    pdf = @contract.signed_contract ? @contract.signed_contract : @contract.blank_contract

    last_page = 1

    File.open(pdf.document.path, "rb") do |io|
      reader = PDF::Reader.new(io)
      last_page = reader.pages.count
    end

    send_data File.new(RGhost::Convert.new(pdf.document.path).to(:png, resolution: 300, multipage: true, range: last_page..last_page)[0]).read
  end

  def autosign
    @contract = current_user.contracts.find(params[:id])

    pdf = @contract.blank_contract

    date_of_signature = Time.now
    digital_signature = current_user.sign("#{ date_of_signature } #{ @contract.id }")

    autosigned = pdf.autosign(params[:signature_position].map(&:to_f), current_user.signature_data, date_of_signature, digital_signature)
    autosigned.document_type = 'signed_contract'
    autosigned.attachable = @contract
    autosigned.save!

    if @contract.request.accepted?
      @contract.contract_verified = true
    end
    @contract.save!

    @contract.user_signed_notification

    render nothing: true
  end

  def autosign_widget
    unless current_user.valid?
      cookies[:autosign_track] = params[:id]
      flash[:alert] = 'Um Verträge abschließen zu können, bitte deine Daten vervollständigen (Es ist nicht notwendig das Passwort erneut einzugeben).'
      render status: 500, json: { url: edit_user_url(current_user) }.to_json
      return
    end

    if current_user.signature_data.present?
      @contract = current_user.contracts.find(params[:id])
      render 'autosign', layout: nil
    else
      cookies[:autosign_track] = params[:id]
      flash[:alert] = 'Um autoSIGN benutzen zu können musst du deine Unterschrift hinterlegen.'

      render status: 500, json: { url: edit_signature_user_url(current_user) }.to_json
    end
  end

  # PATCH/PUT /contracts/1
  # PATCH/PUT /contracts/1.json
  def update
    respond_to do |format|
      if @contract.update(contract_params)
        format.html { redirect_to @contract, notice: 'Contract was successfully updated.' }
        format.json { render :show, status: :ok, location: @contract }
      else
        format.html { render :edit }
        format.json { render json: @contract.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contracts/1
  # DELETE /contracts/1.json
  def destroy
    @contract.destroy
    respond_to do |format|
      format.html { redirect_to contracts_url, notice: 'Contract was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contract
      @contract = Contract.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def contract_params
      params.require(:contract).permit(:internet)
    end
end

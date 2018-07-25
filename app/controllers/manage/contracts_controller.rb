module Manage
  class ContractsController < ManageController
    def index
      user_columns = %w{firstname lastname address zip city country phone mobile fax bank_name bank_account_number bank_code iban bic direct_debit birthdate email bank_account_holder kreditoren_nr debitoren_nr anrede}
      contract_columns = %w{id price_in_cents deposit_in_cents internet extras_in_cents start_date end_date rentable_item_id}

      csv_data = CSV.generate({:col_sep => ';'}) do |csv|
        csv << contract_columns + ['rentable_item_number', 'is_signed', 'is_deposit_paid'] + user_columns + ['contract_created_at', 'is_valid']
        current_account.contracts.valid.each do |contract|
          csv << contract_columns.map { |c| contract.send c } + [contract.rentable_item.number, contract.contract_verified || contract.verified?, contract.deposit_paid || contract.verified?] + contract.user.attributes.values_at(*user_columns) + [contract.created_at, contract.verified?]
        end
      end

      send_data(csv_data, :filename => "contracts.csv", :type => :csv, :disposition => 'attachment')
    end

    def edit
      @contract = current_account.contracts.find(params[:id])
      @movable_to = current_account.rentable_items.select do |ri|
        @contract.rentable_item = ri

        @contract.valid?
      end

      @contract = current_account.contracts.find(@contract.id)
      render layout: nil
    end

    def download
      @contract = current_account.contracts.find(params[:id])

      if params[:document_type] == 'blank_contract'
        attachment = @contract.blank_contract
      elsif params[:document_type] == 'signed_contract'
        attachment = @contract.signed_contract(true)
      end
      send_file attachment.document.path
    end

    def autosign
      @contract = current_account.contracts.find(params[:id])
      pdf = @contract.signed_contract

      date_of_signature = Time.now
      digital_signature = current_user.sign("#{ date_of_signature } #{ @contract.id }")

      autosigned = pdf.autosign(params[:signature_position].map(&:to_f), current_user.signature_data, date_of_signature, digital_signature)
      autosigned.document_type = 'signed_contract_account'
      autosigned.save!

      @contract.landlord_signed_notification

      render nothing: true
    end

    def autosign_widget
      if current_user.signature_data.present?
        @contract = current_account.contracts.find(params[:id])
        render 'contracts/autosign', layout: nil
      else
        flash[:alert] = 'Um autoSIGN benutzen zu können musst du deine Unterschrift hinterlegen.'

        render status: 500, json: {url: edit_signature_user_url(current_user)}.to_json
      end
    end

    def preview
      @contract = current_account.contracts.find(params[:id])
      pdf = @contract.signed_contract ? @contract.signed_contract(true) : @contract.blank_contract

      Rails.logger.info RGhost::Convert.new(pdf.document.path).to(:png, resolution: 300, multipage: true).inspect

      last_page = 1

      File.open(pdf.document.path, "rb") do |io|
        reader = PDF::Reader.new(io)
        last_page = reader.pages.count
      end

      send_data File.new(RGhost::Convert.new(pdf.document.path).to(:png, resolution: 300, multipage: true, range: last_page..last_page)[0]).read
    end

    def update
      @contract = current_account.contracts.find(params[:id])

      attrs = contract_params

      a = Attachment.new(attrs.delete(:attachment))

      if a.valid?
        a.attachable = @contract.account
        @contract.attachments << a
      end

      attrs[:billing_item_ids] ||= []

      if @contract.update_attributes(attrs)
        respond_to do |format|
          format.json do
            render json: {success: true}, status: 200
          end
          format.html do
            redirect_to @contract.verified? ? bookings_rentable_items_path(contract_id: @contract.id) : requests_path
          end
        end
      else
        respond_to do |format|
          format.json do
            render json: {contract: @contract.errors}.to_json, status: 400
          end
          format.html do
            redirect_to @contract.verified? ? bookings_rentable_items_path(contract_id: @contract.id) : requests_path
          end
        end
      end
    end

    def show
      @contract = current_account.contracts.find(params[:id])

      respond_to do |format|
        format.json do
          render json: {
              details: {
                  range: "#{I18n.l @contract.start_date } -#{I18n.l @contract.end_date}",
                  fullname: @contract.user.fullname,
                  deposit: @contract.deposit_paid?
              }
          }
        end
      end
    end

    def move_outs
      @month = (params[:month] || Date.today.month).to_i
      @year = (params[:year] || Date.today.year).to_i

      @min_year = current_account.contracts.empty? ? Date.today.year : current_account.contracts.minimum(:start_date).year
      @max_year = current_account.contracts.empty? ? Date.today.year : current_account.contracts.maximum(:end_date).year

      @contracts = (current_account.contracts.move_outs(@month, @year) - current_account.contracts.relocations_outbound(@month, @year))
    end

    def move_ins
      @month = (params[:month] || Date.today.month).to_i
      @year = (params[:year] || Date.today.year).to_i

      @min_year = current_account.contracts.empty? ? Date.today.year : current_account.contracts.minimum(:start_date).year
      @max_year = current_account.contracts.empty? ? Date.today.year : current_account.contracts.maximum(:end_date).year

      @contracts = (current_account.contracts.move_ins(@month, @year) - current_account.contracts.relocations_inbound(@month, @year))
    end

    def relocations
      @month = (params[:month] || Date.today.month).to_i
      @year = (params[:year] || Date.today.year).to_i

      @min_year = current_account.contracts.empty? ? Date.today.year : current_account.contracts.minimum(:start_date).year
      @max_year = current_account.contracts.empty? ? Date.today.year : current_account.contracts.maximum(:end_date).year

      @relocations_inbound = current_account.contracts.relocations_inbound(@month, @year)
      @relocations_outbound = current_account.contracts.relocations_outbound(@month, @year)
    end

    def generate_bill
      contract = Contract.find(params[:id])

      file = CustomDocumentGenerator.contract_bill(contract, current: params[:current] == 'true')

      send_file File.open(file),
                filename: "Abrechnung #{contract.id} - #{ contract.rentable_item.number } - #{ contract.user.fullname } - #{ params[:current] == 'true' && '(vorläufig)' }.pdf"
    end

    def deliver_bill
      contract = Contract.find(params[:id])
      DeliverBillJob.perform_later(contract, params[:current] == 'true')

      respond_to do |format|
        format.json { render json: { success: true }, status: :ok }
      end
    end

    def regenerate
      contract = Contract.find(params[:id])
      contract.generate_contract

      respond_to do |format|
        format.json do
          render json: { status: 200, msg: 'Contract erfolgreich generiert' }
        end
      end
    end

    private

    def contract_params
      params.require(:contract).permit :start_date, :end_date, :internet, :rentable_item_id, :contract_verified, :deposit_paid, :billing_item_ids, attachment: [:document_type, :document]
    end
  end
end

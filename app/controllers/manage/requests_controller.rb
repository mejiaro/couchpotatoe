module Manage
  class RequestsController < ManageController
    def show
      @request = current_account.requests.find(params[:id])
      render 'popover_content', layout: nil
    end

    def index
      requests = params[:archived] ? current_account.requests.archived : current_account.requests.pending
      @requests = requests.order('updated_at DESC').paginate(page: params[:page], per_page: 10)
    end

    def download
      @request = current_account.requests.find(params[:id])
      send_file @request.contract.attachments.where(document_type: params[:document_type]).first.document.path
    end

    def verify
      contract = current_account.requests.find(params[:id]).contract
      case params[:document_type]
      when 'signed_contract' then contract.contract_verified = true
      when 'passport' then contract.passport_verified = true
      end
      contract.save!
      redirect_to requests_path
    end

    def update
      @request = current_account.requests.find(params[:id])

      if request_params[:accepted] == 'true'
        @request.accepted_by = current_user

        RequestMailer.after_accepted_user(@request).deliver_later
      end

      @request.update_attributes!(request_params)
      redirect_to requests_path
    end

   private

    def request_params
      params.require(:request).permit(:accepted, :passport_verified, :contract_verified, :deposit_paid, :denied, :accepted_by_id)
    end
  end
end

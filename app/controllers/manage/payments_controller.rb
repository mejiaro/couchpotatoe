module Manage
  class PaymentsController < ManageController
    before_action :set_contract
    before_action :set_payment, only: [:edit, :update, :destroy]
    before_action :set_receivable, only: [:new, :edit]

    def new
      @payment = @contract.payments.build
      respond_with(@payment)
    end

    def edit
    end

    def create
      @payment = @contract.payments.build(payment_params)
      @payment.save
      redirect_to contract_receivables_path(@contract)
    end

    def update
      @payment.update(payment_params)
      redirect_to contract_receivables_path(@contract)
    end

    def destroy
      @payment.destroy
      redirect_to contract_receivables_path(@contract)
    end

    private

    def set_contract
      @contract = current_account.contracts.find(params[:contract_id])
    end

    def set_payment
      @payment = @contract.payments.find(params[:id])
    end

    def set_receivable
      if params[:receivable_id]
        @receivable = @contract.receivables.find(params[:receivable_id])
      end
    end

    def payment_params
      params[:payment][:amount].gsub!(',', '.') if params[:payment][:amount]
      params.require(:payment).permit(:amount, :paid_on, :name, :receivable_id)
    end
  end
end
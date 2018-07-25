module Manage
  class ReceivablesController < ManageController
    before_action :set_contract
    before_action :set_receivable, only: [:show, :edit, :update, :destroy, :refusal]

    def index
      @receivables = current_account.contracts.find(params[:contract_id]).receivables
      @payments = current_account.contracts.find(params[:contract_id]).payments

      @receivables_and_payments = (@receivables.to_a + @payments.to_a).sort_by(&:date)

      respond_with(@receivables)
    end

    def show
      respond_with(@receivable)
    end

    def new
      @receivable = @contract.receivables.build
      respond_with(@receivable)
    end

    def edit
    end

    def create
      @receivable = @contract.receivables.build(receivable_params)
      @receivable.save
      redirect_to contract_receivables_path(@contract)
    end

    def update
      @receivable.update(receivable_params)
      respond_to do |format|
        format.html { redirect_to contract_receivables_path(@contract) }
        format.js { render nothing: true }
      end
    end

    def destroy
      @receivable.destroy
      redirect_to contract_receivables_path(@contract)
    end

    def refusal
      new_receivable = @receivable.dup
      new_receivable.save

      @receivable.failed_on = Date.today
      @receivable.save

      if params[:billing_cycle]
        redirect_to billing_cycles_path(year: @receivable.billing_cycle.year, month: @receivable.billing_cycle.month)
      else
        redirect_to contract_receivables_path(@contract)
      end
    end

   private

    def set_contract
      @contract = current_account.contracts.find(params[:contract_id])
    end

    def set_receivable
      @receivable = @contract.receivables.find(params[:id])
    end

    def receivable_params
      params[:receivable][:price].gsub!(',', '.') if params[:receivable][:price]
      params.require(:receivable).permit(:billable_id, :billable_type, :due_since, :amount, :paid, :failed, :price, :failed_on)
    end
  end
end

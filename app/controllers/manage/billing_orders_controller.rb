module Manage
  class BillingOrdersController < ManageController
    def create
      if params[:billing_cycle_id]
        @billing_order = current_account.billing_orders.build
        @billing_order.receivables = current_account.billing_cycles.find(params[:billing_cycle_id]).receivables.direct_debit.paid(false)
        @billing_order.direct_debit = true
      end

      if @billing_order.save
        redirect_to billing_cycles_path
      end
    end

    def export_sepa
      missing = []
      missing << 'Kontoeigentümer' if current_account.bank_account_owner.blank?
      missing << 'IBAN' if current_account.iban.blank?
      missing << 'BIC' if current_account.bic.blank?
      missing << 'Gläubiger-ID' if current_account.creditor_id.blank?

      unless missing.blank?
        flash[:notice] = "In den Einstellunen fehlt: #{missing.join(', ')}"
        redirect_to :action => billing_cycles_path
        return
      end

      @billing_cycle = current_account.billing_cycles.find(params[:id])

      if params[:zip]
        Rails.logger.info @billing_order.to_zip.inspect * 30
        send_file(@billing_order.to_zip, :filename => @billing_order.billable.name + '.zip', :type => :zip, :disposition => 'attachment')
      else
        filename = "SEPA-#{Date.current.year}-#{Date.current.month}-#{Date.current.day}-#{current_account.token}-#{SecureRandom.hex[0..5]}.xml"
        send_data(@billing_order.to_xml, :filename => filename, :type => :xml, :disposition => 'attachment')
      end
    end
  end
end

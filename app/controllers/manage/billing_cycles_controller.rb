module Manage
  class BillingCyclesController < ManageController
    def index
      @billing_cycle = current_account.billing_cycles.find_by_month_and_year(params[:month] || Date.today.month, params[:year] || Date.today.year)

      @billing_cycles = current_account.billing_cycles.where(year: params[:year] || Date.today.year)
      (@billing_cycles.minimum(:month) - 1).times { |i| @billing_cycles.unshift(BillingCycle.new)} if @billing_cycles.minimum(:month).present?
      (12 - @billing_cycles.maximum(:month)).times { |i| @billing_cycles.push(BillingCycle.new)} if @billing_cycles.maximum(:month).present?
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


      filename = "SEPA-#{Date.current.year}-#{Date.current.month}-#{Date.current.day}-#{current_account.token}-#{SecureRandom.hex[0..5]}.xml"
      send_data(@billing_cycle.to_sepa, :filename => filename, :type => :xml, :disposition => 'attachment')
    end

    def all_paid
      @billing_cycle = current_account.billing_cycles.find(params[:id])

      t = Time.now
      @billing_cycle.receivables.paid(false).each { |r| r.payed_on = t; r.save! }

      redirect_to billing_cycles_path
    end
  end
end

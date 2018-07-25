module Manage
  class AccountsController < ManageController
    def edit
    end

    def update
      attrs = account_params

      if attrs[:bill_template]
        bill_template_file = attrs.delete(:bill_template)

        save_at = "#{Rails.env.production? ? '/var/www/rails/couchpotatoe/shared' : Rails.root}/assets/bill_template_#{ current_account.id }_#{ Time.now.to_i }.odt"

        File.open(save_at, 'wb') do |file|
          file.write(bill_template_file.read)
        end

        current_account.update_attribute :bill_template, save_at
        flash[:notice] = 'Dokumentenvorlage erfolgreich hochgeladen'
        redirect_to edit_account_path(current_account)
        return
      end

      if attrs[:contract_template]
        contract_template_file = attrs.delete(:contract_template)

        save_at = "#{Rails.env.production? ? '/var/www/rails/couchpotatoe/shared' : Rails.root}/assets/contract_template_#{ current_account.id }_#{ Time.now.to_i }.odt"

        File.open(save_at, 'wb') do |file|
          file.write(contract_template_file.read)
        end

        current_account.update_attribute :contract_template, save_at
        flash[:notice] = 'Dokumentenvorlage erfolgreich hochgeladen'
        redirect_to edit_account_path(current_account)
        return
      end

      a = Attachment.new(attrs.delete(:attachment))

      if a.valid?
        a.save
        current_account.attachments << a
      end

      if current_account.save && current_account.update_attributes(attrs)
        flash[:notice] = 'Erfolgreich gespeichert.'
        if current_account.domain != request.subdomain
          redirect_to "http://#{current_account.domain}.#{get_host_without_www(root_url)}\/"
        else
          redirect_to edit_account_path(current_account)
        end
      else
        flash[:alert] = 'Fehlgeschlagen.'
        render :edit
      end
    end

    def bill_template
      if current_account.bill_template.nil? || !File.exist?(current_account.bill_template)
        flash[:alert] = 'Sie haben noch keine Abrechnungsvorlage hochgeladen'
        redirect_to edit_account_path(current_account)
      else
        send_file File.open(current_account.bill_template)
      end
    end

    def contract_template
      if current_account.contract_template.nil? || !File.exist?(current_account.contract_template)
        flash[:alert] = 'Sie haben noch keine Vertragsvorlage hochgeladen'
        redirect_to edit_account_path(current_account)
      else
        send_file File.open(current_account.contract_template)
      end
    end

    def ebics_letter
      if current_account.ebics_ini? && current_account.ebics_hia?
        render html: current_account.ebics_client.ini_letter(current_account.bank_name).html_safe
      end
    end

   private

    def account_params
      ci = [:ci_dark_color, :ci_bright_color, :public_name, :domain, { attachment: [:document_type, :document] }, :bill_template, :contract_template]
      ebics = [:ebics_user_id, :ebics_host_id, :ebics_partner_id, :ebics_url]
      payments_bank_account = [:creditor_id, :bank_account_owner, :bank_name, :iban, :bic]
      deposits_bank_account = [:deposits_bank_account_owner, :deposits_bank_name, :deposits_iban, :deposits_bic]
      company_address = [:company, :company_address, :company_zip, :company_city, :company_country]
      misc = [:paypal_deposit, :only_students, :only_first_of_month, :at_least_one_year_rental_period]
      params.require(:account).permit *(ebics + payments_bank_account + deposits_bank_account + company_address + ci + misc)
    end
  end
end

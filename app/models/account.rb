class Account < ActiveRecord::Base
  include FlagShihTzu

  validates :domain, :public_name, presence: true
  validates :domain, uniqueness: true

  has_one :stylesheet, as: :themeable

  has_many :container_items
  has_many :rentable_items
  has_many :requests
  has_many :billing_cycles, -> { distinct }
  has_many :receivables, through: :billing_cycles
  has_many :payments, through: :receivables

  has_many :billing_items

  has_many :contracts, through: :rentable_items
  has_many :requests, through: :rentable_items

  has_many :users, -> { distinct }, through: :contracts
  has_many :interviews, -> { distinct }, through: :users

  has_many :assignments
  has_many :interview_availabilities, through: :assignments

  has_many :subjects

  has_many :attachments, as: :attachable

  has_one :terms

  has_flags 1 => :ebics_ini,
            2 => :ebics_hia,
            3 => :paypal_deposit,
            4 => :only_students,
            5 => :only_first_of_month,
            6 => :at_least_one_year_rental_period

  def image?
    attachments.where(document_type: 'image').any?
  end

  def image
    attachments.where(document_type: 'image').order('updated_at desc').first
  end

  def address
    company_address
  end

  def employees
    self.assignments.map(&:user)
  end

  def full_address
    [company_address, company_zip, company_city, company_country].join(' ')
  end

  def ci_dark_color=(color)
    self.stylesheet ||= Stylesheet.new(variables: {})
    self.stylesheet.variables ||= {}
    self.stylesheet.variables["dark-color"] = color
    self.stylesheet.save!
  end

  def ci_bright_color=(color)
    self.stylesheet ||= Stylesheet.new(variables: {})
    self.stylesheet.variables ||= {}
    self.stylesheet.variables["bright-color"] = color
    self.stylesheet.save!
  end

  def ci_dark_color
    @ci_dark_color ||= (self.stylesheet.present? ? self.stylesheet.variables['dark-color'] : nil)
  end

  def ci_bright_color
    @ci_bright_color ||= (self.stylesheet.present? ? self.stylesheet.variables['bright-color'] : nil)
  end

  [:bank_account_owner, :bank_name, :iban, :bic].each do |bank_data_attribute|
    define_method :"deposits_#{bank_data_attribute}" do
      read_attribute(:"deposits_#{bank_data_attribute}").present? ? read_attribute(:"deposits_#{bank_data_attribute}") : read_attribute(bank_data_attribute)
    end
  end

  def ebics_data_present?
    [ebics_user_id.present?, ebics_host_id.present?, ebics_partner_id.present?, ebics_url.present?].all?
  end

  def ebics_client
    @ebics_client ||= if (key_file = attachments.find_by_document_type('ebics_keys'))
                        key_file = File.open(key_file.document.path)
                        Epics::Client.new(key_file, 'lulzsec', ebics_url, ebics_host_id, ebics_user_id, ebics_partner_id)
                      else
                        ebics_client = Epics::Client.setup("lulzsec", ebics_url, ebics_host_id, ebics_user_id, ebics_partner_id)

                        tmpfile = Tempfile.new(['ebics_keys', '.txt'])
                        ebics_client.save_keys(tmpfile.path)
                        key_file = self.attachments.build(document_type: 'ebics_keys', document: File.open(tmpfile.path))
                        key_file.save!

                        ebics_client
                      end
  end

  def self.ebics_initialize!
    self.all.each do |account|
      if account.ebics_data_present?
        unless account.ebics_ini

          if account.ebics_client.INI
            account.ebics_ini = true
            account.save
          end
        end

        unless account.ebics_hia
          if account.ebics_client.HIA
            account.ebics_hia = true
            account.save
          end
        end
      end
    end
  end
end

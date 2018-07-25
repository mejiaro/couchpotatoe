require 'open-uri'

class User < ActiveRecord::Base
  devise :database_authenticatable, :recoverable, :rememberable, :validatable, :trackable, :lockable, :encryptable, :omniauthable, :omniauth_providers => [:facebook]
  has_one :image, as: :attachable_image

  has_many :requests
  has_many :contracts
  has_many :assignments, foreign_key: :employee_id

  has_many :rentable_items, through: :contracts

  has_many :receivables, through: :contracts

  has_many :subjects

  has_many :messages, as: :author

  has_many :interviews, as: :owner

  validates :email, uniqueness: true, presence: true
  validates :anrede, :firstname, :lastname, presence: true
  validates :birthdate, presence: true, on: :update
  validates :address, :zip, :city, presence: true, on: :update
  validates :password, :password_confirmation, presence: true, on: :create

  # validates :iban, :bic, presence: true, on: :update

  validates_with SEPA::IBANValidator, unless: -> (u) { u.iban.blank? }
  validates_with SEPA::BICValidator, unless: -> (u) { u.bic.blank? }

  after_save :generate_contracts

  def self.from_omniauth(auth)
    user = self.find_or_initialize_by(email: auth.info.email)
    user.firstname ||= auth.info.first_name
    user.lastname ||= auth.info.last_name
    user.image_from_url(auth.info.image) if user.image.blank?
    user.password = Devise.friendly_token[0,20] unless user.encrypted_password.present?
    return user if user.save(validate: false)
  end

  def fullname
    "#{firstname} #{lastname}"
  end

  def bank_data_present?
    !iban.blank? && !bic.blank?
  end

  def image_from_url(url)
    extname = File.extname(url)
    basename = File.basename(url, extname)

    file = Tempfile.new([basename, extname])
    file.binmode

    open(URI.parse(url)) do |data|
      file.write data.read
    end

    file.rewind

    self.image = Image.new(image: file)
  end

  def sign(string)
    digest = OpenSSL::Digest::SHA256.new
    Base64.strict_encode64(self.rsa.sign digest, string)
  end

  def rsa
    if read_attribute(:rsa).blank?
      key = OpenSSL::PKey::RSA.new(1024)
      self.rsa = key.to_pem
      self.save(validate: false)
    end

    OpenSSL::PKey::RSA.new(read_attribute(:rsa))
  end

  def default_account
    if !self.assignments.blank? && self.assignments.find { |a| !a.account.blank? }
      self.assignments.all.max_by { |as| as.account.employees.count }.account
    else
      user_account = Account.new
      user_account.domain = self.id
      user_account.public_name = "#{self.firstname[0] }. #{ self.lastname }"

      user_account.company_address = self.address
      user_account.company_city = self.city
      user_account.company_zip = self.zip
      user_account.company_country = self.country
      user_account.company_address = self.address
      assignment = self.assignments.build(account: user_account)

      [user_account, assignment].each(&:save!)

      return user_account
    end
  end

  def age
    now = Time.now.utc.to_date
    now.year - birthdate.year - ((now.month > birthdate.month || (now.month == birthdate.month && now.day >= birthdate.day)) ? 0 : 1)
  end

  def generate_contracts
    self.requests.pending.each do |r|
      GenerateContractJob.perform_later(r.contract)
    end
  end

  def self.search(term)
    if !term.blank?
      conditions = [
          '(LOWER(CONCAT(firstname, " ", lastname)) LIKE LOWER(:term))',
          '(LOWER(firstname) LIKE LOWER(:term))',
          '(LOWER(lastname) LIKE LOWER(:term))'
      ]

      self.where(conditions.join(' OR '), term: "#{term}%")
    else
      raise ArgumentError, 'Must be called with a valid search term as only parameter.'
    end
  end
end

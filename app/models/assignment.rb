class Assignment < ActiveRecord::Base

  belongs_to :account
  belongs_to :user, foreign_key: :employee_id

  has_many :messages, as: :author

  has_many :interview_availabilities, as: :owner

  def fullname
    "#{user.fullname} - #{account.public_name}"
  end

  def image
    user.image
  end
end

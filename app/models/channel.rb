class Channel < ActiveRecord::Base
  belongs_to :account
  has_many :subjects

  belongs_to :relatable, polymorphic: true
end

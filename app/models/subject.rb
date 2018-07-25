class Subject < ActiveRecord::Base
  belongs_to :user
  belongs_to :account
  has_many :messages
  belongs_to :channel

  validates :account, presence: true
  validates :user, presence: true
  validates :title, presence: true
end

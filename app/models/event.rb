class Event < ActiveRecord::Base
  belongs_to :schedulable, polymorphic: true
  belongs_to :owner, polymorphic: true
end

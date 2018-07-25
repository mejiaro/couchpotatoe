class Employee < ActiveRecord::Base
  has_many :assignments

  def fullname
    "#{firstname} #{lastname}"
  end

  def image
    nil
  end
end

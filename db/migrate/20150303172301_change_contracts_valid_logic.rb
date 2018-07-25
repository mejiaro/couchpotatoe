class ChangeContractsValidLogic < ActiveRecord::Migration
  def up
    Contract.valid.each do |c|
      c.valid? ? c.state = 'valid' : c.state = 'invalid'
      c.save(validate: false)
    end
  end

  def down

  end
end

class AccountsLanguages < ActiveRecord::Migration
  def self.up
    create_table :accounts_languages, :id => false do |t|
      t.references :language, :account
    end
  end

  def self.down
    drop_table :accounts_languages
  end
end

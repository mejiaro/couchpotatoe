class AddColumnDocumentTypeToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :document_type, :string
  end

  def self.down
    remove_column :accounts, :document_type
  end
end

class RemoveColumnsDraftAndDocumentTypeFromAccounts < ActiveRecord::Migration
  def self.up
    remove_column :accounts, :draft
    remove_column :accounts, :document_type
  end

  def self.down
    add_column :accounts, :draft, :boolean
    add_column :accounts, :document_type, :string
  end
end

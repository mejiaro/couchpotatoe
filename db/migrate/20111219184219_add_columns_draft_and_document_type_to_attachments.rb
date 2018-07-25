class AddColumnsDraftAndDocumentTypeToAttachments < ActiveRecord::Migration
  def self.up
    add_column :attachments, :draft, :boolean
    add_column :attachments, :document_type, :string
  end

  def self.down
    remove_column :attachments, :document_type
    remove_column :attachments, :draft
  end
end

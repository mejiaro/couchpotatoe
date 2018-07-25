class AddColumnsToAttachment < ActiveRecord::Migration
  def self.up
    add_column :attachments, :document_file_size, :integer
    add_column :attachments, :document_file_name, :string
    add_column :attachments, :document_file_type, :string
    add_column :attachments, :document_updated_at, :datetime
    add_column :attachments, :document_fingerprint, :string

    add_column :attachments, :attachable_id, :integer
    add_column :attachments, :attachable_type, :string
  end

  def self.down
    remove_column :attachments, :document_file_size
    remove_column :attachments, :document_file_name 
    remove_column :attachments, :document_file_type
    remove_column :attachments, :document_updated_at
    remove_column :attachments, :document_fingerprint

    remove_column :attachments, :attachable_id
    remove_column :attachments, :attachable_type
  end
end

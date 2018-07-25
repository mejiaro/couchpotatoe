class AddColumnsNeedsSignatureToAttachments < ActiveRecord::Migration
  def self.up
    add_column :attachments, :needs_signature, :boolean
  end

  def self.down
    remove_column :attachments, :needs_signature
  end
end

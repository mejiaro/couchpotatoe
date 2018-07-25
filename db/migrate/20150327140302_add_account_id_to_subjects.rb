class AddAccountIdToSubjects < ActiveRecord::Migration
  def up
    add_reference :subjects, :account, index: true

    Subject.all.each do |subject|
      if subject.channel.blank? || subject.title.blank?
        subject.destroy
      else
        subject.account = subject.channel.account
        subject.save
      end
    end
  end

  def down
    remove_column :subjects, :account_id, index: true
  end
end

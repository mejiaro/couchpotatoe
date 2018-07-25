class Message < ActiveRecord::Base
  belongs_to :subject
  belongs_to :author, polymorphic: true
  after_create :send_mail


  def by_user?
    author.is_a?(User)
  end

 private

  def recipient_emails
    if by_user?
      [subject.account.employees.compact.map(&:email)]
    else
      [subject.user.email]
    end
  end

  def contextual_subjects_path
    if self.by_user?
      "http://#{subject.account.domain}.couchpotatoe.com/subjects"
    else
      "http://www.couchpotatoe.com/subjects"
    end
  end

  def send_mail
    mail = SendGrid::Mail.new do |m|
      m.to = recipient_emails
      m.from = 'no-reply@couchpotatoe.com'
      m.from_name = 'couchpotatoe'
      m.subject = 'Neue Nachricht'
      m.html = <<HTML
<h2>#{ self.author.fullname }</h2>
<p>#{ self.text }</p>

<p>Auf deinem <a href=#{ contextual_subjects_path }>couchpotatoe Nachrichten-Center</a> kannst du auf diese Nachricht antworten</p>
HTML
    end

    resp = SendGridClient.send(mail)
    Rails.logger.info(resp)
  end
end

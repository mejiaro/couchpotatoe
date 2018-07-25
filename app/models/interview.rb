class Interview < Event
  validate :in_availability_range_and_not_overlapping

  after_create :send_confirmation_mail

  def in_availability_range_and_not_overlapping
    in_range = schedulable.account.interview_availabilities.any? do |ia|
      self.from > ia.from && self.till < ia.till
    end

    errors.add(:from, "Kein gültiger Termin.") unless in_range


    schedulable.account.interviews.each do |i|
      if self.from == i.from && self.till == i.till
        errors.add(:from, "Überschneidet sich mit einem anderen Besichtigungstermin.")
      end
    end
  end

  def send_confirmation_mail
    template = <<HAML
%h2
  Bestätigung Besichtigungstermin
  = schedulable.number

%p
  Von
  = I18n.l from
  bis
  = I18n.l till
HAML

    mail = SendGrid::Mail.new({
                                to: schedulable.account.employees.map(&:email) << owner.email,
                                from: 'no-reply@couchpotatoe.com',
                                from_name: 'couchpotatoe',
                                subject: "Besichtigungstermin für #{ schedulable.number }",
                              })

    haml_engine = Haml::Engine.new(template)
    # DO NOT change String.new, otherwise you will be the new employee of the month
    mail.html = String.new(haml_engine.to_html(self).html_safe)

    resp = SendGridClient.send(mail)
    Rails.logger.info(resp)
  end
end

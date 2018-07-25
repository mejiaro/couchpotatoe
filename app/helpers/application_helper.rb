module ApplicationHelper
  def new_receivables(billing_cycles)
    sum_per_month = billing_cycles.map { |bi| bi.receivables.paid(false).map(&:price).sum }
    (['new'] + sum_per_month).to_json
  end

  def failed_receivables(billing_cycles)
    sum_per_month = billing_cycles.map { |bi| bi.receivables.failed.map(&:price).sum }
    (['failed'] + sum_per_month).to_json
  end

  def paid_receivables(billing_cycles)
    sum_per_month = billing_cycles.map { |bi| bi.receivables.paid(true).map(&:price).sum }
    (['paid'] + sum_per_month).to_json
  end

  def human_sepa_mandate_state_name(mandate_state)
    {'FRST' => 'Erstmalige', 'OOFF' => 'Einmalige', 'RCUR' => 'Wiederholte', 'FNAL' => 'Letztmalige'}[mandate_state]
  end

  def dates_localized_for_select(ds)
    ds.map { |d| [I18n.l(d), d] }
  end

  def request_state_title(object)
    if object.accepted?
      'Anfrager muss unterschreiben'
    else
      'Neue Anfrage'
    end
  end

  def request_actions_partial(object)
    if object.accepted?
      'verify_contract'
    else
      'accept_or_deny'
    end
  end

  def get_host_without_www(url)
    uri = URI.parse(url)
    uri = URI.parse("http://#{url}") if uri.scheme.nil?
    host = uri.host.downcase
    host.start_with?('www.') ? host[4..-1] : host
  end
end

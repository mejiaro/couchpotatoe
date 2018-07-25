set :output, "/var/log/couchpotatoe_recurring.log"

every 5.minutes do
  runner "BillingCycle.update!"
end

every 2.minutes do
  runner "Receivable.mark_paid!"
end

every '0,15,30,45 08-20 * * *' do
  runner 'Request.remind_accepted!'
end

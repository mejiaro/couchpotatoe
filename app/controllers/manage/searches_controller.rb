module Manage
  class SearchesController < ManageController
    def user_contracts
      term = params[:term]

      res = current_account.users.search(term)

      res = res.map { |u| u.contracts.joins(:rentable_item).where('rentable_items.account_id = ?', current_account.id).valid }.flatten.map do |c|

        {
            label: "#{ c.user.fullname } #{ I18n.l c.start_date } - #{ I18n.l c.end_date }",
            value: { id: c.id, starting_time: c.start_date.strftime('%Q').to_i }
        }
      end

      render json: res.to_json
    end
  end
end
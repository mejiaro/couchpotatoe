module Manage
  class BillingItemsController < ManageController
    before_action :set_billing_item, only: [:show, :edit, :update, :destroy]

    def index
      @billing_items = current_account.billing_items.all
      respond_with(@billing_items)
    end

    def show
      respond_with(@billing_item)
    end

    def new
      @billing_item = current_account.billing_items.build
      respond_with(@billing_item)
    end

    def edit
    end

    def create
      @billing_item = current_account.billing_items.build(billing_item_params)
      if @billing_item.save
        redirect_to billing_items_path
      else
        respond_with(@billing_item)
      end
    end

    def update
      if @billing_item.update_attributes(billing_item_params)
        redirect_to billing_items_path
      else
        respond_with(@billing_item)
      end
    end

    def destroy
      @billing_item.destroy
      redirect_to billing_items_path
    end

    private
      def set_billing_item
        @billing_item = current_account.billing_items.find(params[:id])
      end

      def billing_item_params
        params.require(:billing_item).permit(:name, :number, :description, :billing_account, :price, :mode)
      end
  end
end
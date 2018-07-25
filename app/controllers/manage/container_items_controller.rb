module Manage
  class ContainerItemsController < ManageController
    def index
      @container_items = current_account.container_items
    end

    def new
      @container_item = current_account.container_items.build
    end

    def create
      @container_item = current_account.container_items.build(container_item_params)

      if @container_item.save
        redirect_to container_items_path
      else
        render 'new'
      end
    end

    def edit
      @container_item = current_account.container_items.find(params[:id])
    end

    def update
      @container_item = current_account.container_items.find(params[:id])

      if @container_item.update_attributes(container_item_params)
        redirect_to container_items_path
      else
        render 'edit'
      end
    end

    def destroy
      @container_item = current_account.container_items.find(params[:id])

      @container_item.destroy
      redirect_to container_items_path
    end
   private

    def container_item_params
      params.require(:container_item).permit(:name, :address, :city, :zip, :parent_id)
    end
  end
end
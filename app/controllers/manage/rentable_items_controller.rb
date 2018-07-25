module Manage
  class RentableItemsController < ManageController
    before_action :fetch_rentable_items, only: [:bookings]

    def show
      @rentable_item = current_account.rentable_items.find(params[:id])
      respond_to  do |format|
        format.js { render layout: nil }
        format.html { redirect_to rentable_items_path(id: params[:id])}
      end
    end

    def edit
      @rentable_item = current_account.rentable_items.find(params[:id])
      respond_to  do |format|
        format.js { render layout: nil }
      end
    end


    def new
      @rentable_item = current_account.rentable_items.build
      respond_to  do |format|
        format.html { render '_form.html.haml', layout: nil }
      end
    end


    def update
      @rentable_item = current_account.rentable_items.find(params[:id])

      if params[:rentable_item][:item_type_attributes]
        attrs = params[:rentable_item].delete(:item_type_attributes).split(',')
        @rentable_item.item_type_attributes = []
        attrs.each do |attr|
          item_type_attribute = ItemTypeAttribute.where(value: attr).first || ItemTypeAttribute.create!(value: attr)
          @rentable_item.item_type_attributes << item_type_attribute
        end

        @rentable_item.save!
      else
        @rentable_item.update_attributes(rentable_item_params)
      end


      render nothing: true
    end

    def index
      @rentable_item = RentableItem.new
      if params[:container_item_id]
        @rentable_items = RentableItem.where id: current_account.container_items.find(params[:container_item_id]).descendant_rentable_items
      else
        @rentable_items =  current_account.rentable_items.order('created_at DESC')
      end

      if params[:blocked].present?
        @rentable_items = @rentable_items.where(blocked: params[:blocked])
      end

      if params[:query]
        @rentable_items = @rentable_items.where('number LIKE :query OR description LIKE :query', query: "%#{params[:query]}%")
      end

      page = params[:page]
      if params[:id] && !page
        @highlighted = @rentable_items.find(params[:id])
        count = @rentable_items.where('created_at > ?', @highlighted.created_at).count
        page = (count / 15) + 1
      end

      @rentable_items = @rentable_items.paginate(page: page, per_page: 15)

      respond_to do |format|
        format.html do
          if request.fullpath == '/'
            redirect_to requests_path
          end
        end
      end
    end

    def bookings
      @years = current_account.contracts.any? ? (current_account.contracts.minimum('start_date').year..current_account.contracts.maximum('end_date').year).to_a : [2014]

      if params[:requested_booking] && (requested_booking = Contract.find(params[:requested_booking]))
        requested_booking_data = {
          starting_time: requested_booking.start_date.strftime('%Q').to_i,
          ending_time: requested_booking.end_date.strftime('%Q').to_i,
          contract_id: requested_booking.id,
          label: "Anfrage: #{ requested_booking.user.fullname }",
          request: true
        }

        @requested_booking = { id: requested_booking.rentable_item.id, label: requested_booking.rentable_item.number, times: [requested_booking_data] }
      end

      @focus_contract_id = params[:contract_id]

      respond_to do |format|
        format.html

        format.json do
          if current_account.contracts.valid.any?
            @bookings = @rentable_items.map do |ri|

              timeline_data = ri.contracts.valid.map do |c|
                {
                  starting_time: c.start_date.strftime('%Q').to_i,
                  ending_time: c.end_date.strftime('%Q').to_i,
                  contract_id: c.id,
                  label: c.user.present? ? c.user.fullname : '',
                  deposit: c.deposit_paid?
                }
              end

              timeline_data += @requested_booking[:times] if @requested_booking && @requested_booking[:id] == ri.id

              { id: ri.id, label: ri.display_name_with_container_items, times: timeline_data }
            end
          else
            @bookings = []
          end
          render json: @bookings.to_json
        end
      end
    end

    def create
      @rentable_item = current_account.rentable_items.create!(rentable_item_params)
      redirect_to rentable_items_path
    end

    def destroy
      @rentable_item = current_account.rentable_items.find(params[:id])
      @rentable_item.destroy
      render nothing: true
    end

    def images
      @rentable_item = current_account.rentable_items.find(params[:id])
      params[:files].each do |file|
        image = @rentable_item.images.build
        image.image = file
        image.save
      end
      render 'images', layout: nil
    end

    def update_image
      @rentable_item = current_account.rentable_items.find(params[:id])
      image = @rentable_item.images.find(params[:image_id])
      image.update_attributes!(presentation_order_position: params[:presentation_order_position])
      render nothing: true
    end

    def destroy_image
      @rentable_item = current_account.rentable_items.find(params[:id])
      image = @rentable_item.images.find(params[:image_id])
      image.destroy!
      render nothing: true
    end

    def item_type_attributes
      respond_to do |format|
        format.json do
          render json: ItemTypeAttribute.all.map(&:value)
        end
      end
    end

   private

    def rentable_item_params
      params.require(:rentable_item).permit(:number, :description, :price, :deposit, :size, :blocked, :address, :zip, :city, :country, :room_count, :container_item_id, :earliest_available, :ad_name)
    end

    def fetch_rentable_items
      if params[:container_item_id]
        @rentable_items = current_account.container_items.find(params[:container_item_id]).descendant_rentable_items
      else
        @rentable_items = current_account.rentable_items.order('number ASC')
      end
    end
  end
end

class CalendarsController < ApplicationController
  before_filter :authenticate_user!
  def index
    @rentable_item = RentableItem.find(params[:rentable_item_id]) unless params[:rentable_item_id].blank?
    respond_to do |format|
      format.html
      format.json do
        if @rentable_item
          json =  @rentable_item.account.interview_availabilities.map do |ia|
            Range.new(ia.from.to_i, ia.till.to_i).step(30.minutes).map do |seconds_since_epoch|
              time = Time.at(seconds_since_epoch)
              interview = Interview.new({schedulable: @rentable_item, from: time, till: time + 30.minutes})
              if interview.valid?
                { title: '', id: ia.id, start: interview.from, end: interview.till, className: 'interview-availability' }
              end
            end
          end.flatten.compact
          render json: json
        else
          json = current_user.interviews.map do |interview|
            { title: "#{interview.schedulable.number} #{interview.schedulable.account.public_name}", id: interview.id, start: interview.from, end: interview.till }
          end
          render json: json
        end
      end
    end
  end

  def schedule_interview
    from = Time.zone.parse(params[:start])
    till = Time.zone.parse(params[:end])
    interview = Interview.new(owner: User.find(current_user.id), from: from, till: till, schedulable: RentableItem.find(params[:rentable_item_id]))

    respond_to do |format|
      format.json do
        if interview.save
          render json: { success: true }
        else
          Rails.logger.info(interview.errors.inspect)
          render json: { failure: true }
        end
      end
    end
  end
end

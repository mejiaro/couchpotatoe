module Manage
  class CalendarsController < ManageController
    def index
      respond_to do |format|
        format.html
        format.json do
          ias = current_assignment.interview_availabilities.map do |ia|
            { title: 'Anwesend für Besichtigungen', id: ia.id, start: ia.from, end: ia.till }
          end

          is = current_account.interviews.map do |i|
            { title: "Besichtigung #{ i.owner.fullname } #{ i.schedulable.number }", id: i.id, start: i.from, end: i.till }
          end
          json = ias + is
          render json: json
        end
      end
    end

    def interview_availability


      respond_to do |format|
        format.json do
          from = Time.zone.parse(params[:start])
          till = Time.zone.parse(params[:end])
          ia = InterviewAvailability.new(from: from, till: till, owner: current_assignment)

          if ia.save
            render json: { success: true }
          end
        end
      end
    end
  end
end

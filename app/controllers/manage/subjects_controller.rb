module Manage
  class SubjectsController < ManageController
    before_action :set_subject, only: [:show, :edit, :update, :destroy, :send_message]

    # GET /subjects
    # GET /subjects.json
    def index
      @subjects = current_account.subjects.order('created_at DESC')
      @subject = @subjects.first

      respond_to do |format|
        format.html
      end
    end

    # GET /subjects/1
    # GET /subjects/1.json
    def show
      render layout: nil
    end

    # GET /subjects/new
    # def new
    #   @subject = Subject.new
    # end

    # GET /subjects/1/edit
    # def edit
    # end

    # POST /subjects
    # POST /subjects.json
    def create
      user = current_account.users.find(params[:user_id] || params[:subject][:user_id])
      @subject = user.subjects.build(title: params[:title] || params[:subject][:title])

      @subject.account = current_account

      respond_to do |format|
        if @subject.save
          format.html { redirect_to subjects_path }
          format.json { render :show, status: :created, location: @subject }
        else
          format.html { redirect_to subjects_path }
          format.json { render json: @subject.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /subjects/1
    # PATCH/PUT /subjects/1.json
    def send_message
      m = @subject.messages.build author: current_assignment, text: params[:text]

      respond_to do |format|
        if m.save
          format.html { render 'show', layout: nil }
          format.json { render :show, status: :ok, location: @subject }
        else
          format.html { render nothing: true }
          format.json { render json: @subject.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /subjects/1
    def destroy
      @subject.destroy
      head :no_content
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_subject
      @subject = current_account.subjects.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def subject_params
      params[:subject]
    end
  end
end

class TrainingRecordsController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @training_records = current_user.training_records.order(training_day: :desc)
  end

  def edit
    @training_record = current_user.training_records.find(params[:id])
  end

  def new
    @training_record = TrainingRecord.new
  end

  def create
    @training_record = current_user.training_records.new(training_record_params)

    if @training_record.save
      redirect_to training_records_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
      @training_record = current_user.training_records.find(params[:id])

    if @training_record.update(training_record_params)
      redirect_to training_records_path
    else
     render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @training_record = current_user.training_records.find(params[:id])
    @training_record.destroy

    redirect_to training_records_path
  end


  private

  def training_record_params
    params.require(:training_record).permit(
      :training_day,
      :training_name,
      :weight_kg,
      :reps,
      :set_count
    )
  end
end
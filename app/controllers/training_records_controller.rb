class TrainingRecordsController < ApplicationController
  before_action :authenticate_user!

  def new
    @training_record = TrainingRecord.new
  end

  def create
    @training_record = current_user.training_records.new(training_record_params)

    if @training_record.save
      redirect_to new_training_record_path
    else
      render :new, status: :unprocessable_entity
    end
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
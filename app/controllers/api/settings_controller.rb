# frozen_string_literal: true

class Api::SettingsController < ApplicationController
  def index
    @calendar = User.find(current_user.id).calendars.find_by(year: params[:calendar_year])
    @settings = @calendar&.settings
  end

  def show; end

  def create
    @calendar = User.find(current_user.id).calendars.find_or_create_by(year: params[:calendar_year])
    @setting = Setting.new(setting_params.merge(calendar_id: @calendar.id))
    @setting.save!
  end

  def update
    Setting.find(params[:id]).update!(setting_params)
  end

  def destroy
    Setting.find(params[:id]).delete
  end

  private

  def setting_params
    params.require(:setting).permit(
      :calendar_id,
      :schedule_of_sunday,
      :schedule_of_monday,
      :schedule_of_tuesday,
      :schedule_of_wednesday,
      :schedule_of_thursday,
      :schedule_of_friday,
      :schedule_of_saturday,
      :total_working_days,
      :period_start_at,
      :period_end_at
    )
  end
end

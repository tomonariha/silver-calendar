# frozen_string_literal: true

module API
  module V1
    module Calendars
      class SettingsController < ApplicationController
        def index
          calendar = current_calendars.find_by(year: params[:calendar_year])
          settings = calendar&.settings
          render json: settings.to_json
        end
      
        def show; end
      
        def create
          calendar = current_calendars.find_or_create_by!(year: params[:calendar_year])
          setting = calendar.settings.new(setting_params)
          setting.save!
          render json: { id: setting.id }
        end
      
        def update
          calendar = current_calendars.find_or_create_by!(year: params[:calendar_year])
          calendar.settings.find(params[:id]).update!(setting_params)
        end
      
        def destroy
          calendar = current_calendars.find_or_create_by!(year: params[:calendar_year])
          calendar.settings.find(params[:id]).destroy!
        end
      
        private
      
        def setting_params
          params.require(:setting).permit(
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
    end
  end
end
    
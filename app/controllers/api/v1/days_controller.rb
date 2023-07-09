# frozen_string_literal: true

module API
  module V1
    class DaysController < ApplicationController
      def destroy
        day = set_calendar.days.find_by(date: set_target_day)
        day&.delete
      end
    
      def update
        day = set_calendar.days.find_or_create_by(date: set_target_day)
        day.update!(schedule: params[:schedule])
      end
    
      private
    
      def set_calendar
        current_calendars.find_or_create_by!(year: params[:year])
      end
    
      def set_target_day
        Date.new(params[:year].to_i, params[:month].to_i, params[:date].to_i)
      end
    end
  end
end

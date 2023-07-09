# frozen_string_literal: true

module API
  module V1
    class CalendarsController < ApplicationController
      def show
        calendar = current_calendars.find_by(year: params[:year])
        @days = calendar&.days
      end
    
      def update
        ActiveRecord::Base.transaction do
          calendar = current_calendars.find_or_create_by!(year: params[:year])
          params['calendar'].each do |day|
            date = Date.parse(day['date'])
            schedule = day['schedule']
            day = calendar.days.find_or_create_by(date:)
            day.update!(schedule:)
          end
          render json: { message:'適用しました' }
        end
      rescue ActiveRecord::RecordInvalid => e
        render json: { error_message:'問題が起きたためデータの保存に失敗しました' }
      end
    
      def index
        @calendars = current_calendars.order('year ASC')
      end
    
      def destroy
        calendar = current_calendars.find_by(year: params[:year])
        calendar.destroy! unless calendar.nil?
      end
    end
  end
end

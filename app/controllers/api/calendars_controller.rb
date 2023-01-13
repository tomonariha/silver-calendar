# frozen_string_literal: true

class Api::CalendarsController < ApplicationController
  def show
    @days = User.find(current_user.id).calendars.find_or_create_by(year: params[:year]).days
  end

  def update
    @calendar = User.find(current_user.id).calendars.find_or_create_by(year: params[:year])
    params['calendar'].each do |day|
      date = Date.parse(day['date'])
      schedule = day['schedule']
      @day = @calendar.days.find_or_create_by(date:)
      @day.update!(schedule:)
    end
  end
end

# frozen_string_literal: true

class Api::AlignmentsController < ApplicationController
  before_action :set_user, :set_calendar, :set_calendar_client, :set_working_times

  def create
    # resultにはGoogleカレンダーからのレスポンスが入る。
    # Googleカレンダーに新しく作ったカレンダーのIDを取得するための処理。
    @result = @client.create_calendar(@calendar)
    calendar_days = @calendar.days
    @client.insert_events(calendar_days, @result.id, @working_times)
  end

  def destroy
    @result = @client.delete_calendar(@calendar)
  end

  def update
    # Googleカレンダーに追加したカレンダーを削除し新しくカレンダーを作り直す
    # 個別に日程の予定を更新するにはevent_idが必要で処理が冗長になるため
    @client.delete_calendar(@calendar)
    @result = @client.create_calendar(@calendar)
    calendar_days = @calendar.days
    @client.insert_events(calendar_days, @result.id, @working_times)
  end

  private

  def set_user
    @user = current_user
  end

  def set_calendar
    @calendar = current_user.calendars.find_by(year: params[:calendar_year])
  end

  def set_calendar_client
    @client = CalendarClient.new(current_user)
  end

  def set_working_times
    @working_times = params
  end
end

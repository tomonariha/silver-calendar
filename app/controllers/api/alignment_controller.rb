# frozen_string_literal: true

class Api::AlignmentController < ApplicationController
  before_action :set_user, :set_calendar, :set_calendar_client

  def create
    #resultにはGoogleカレンダーからのレスポンスが入る。
    #Googleカレンダーに新しく作ったカレンダーのIDを取得するための処理。
    result = @client.create_calendar(@calendar)
    calendar_days = @calendar.days
    @client.insert_events(calendar_days, result.id)
    redirect_to root_path, notice: '書き込みテスト終了'
  end

  def destroy
    @client.delete_calendar(@calendar)
    redirect_to root_path, notice: '削除しました'
  end

  def get_event
    @client.get_event
    redirect_to root_path, notice: '予定を取得しました'
  end

  private

  def set_user
    @user = current_user
  end

  def set_calendar
    @calendar = current_user.calendars.find_by(year: params[:year])
  end

  def set_calendar_client
    @client = CalendarClient.new(current_user)
  end
end

# frozen_string_literal: true

class Api::AlignmentsController < ApplicationController
  before_action :set_user, :set_calendar, :set_calendar_client

  def create
    # resultにはGoogleカレンダーからのレスポンスが入る。
    # Googleカレンダーに新しく作ったカレンダーのIDを取得するための処理。
    result = @client.create_calendar(@calendar)
    calendar_days = @calendar.days
    @client.insert_events(calendar_days, result.id)
    redirect_to root_path, notice: '書き込みテスト終了'
  end

  def destroy
    @client.delete_calendar(@calendar)
    redirect_to root_path, notice: '削除しました'
  end

  def update
    # Googleカレンダーに追加したカレンダーを削除し新しくカレンダーを作り直す
    # 個別に日程の予定を更新するにはevent_idが必要で処理が冗長になるため
    @client.delete_calendar(@calendar)
    result = @client.create_calendar(@calendar)
    calendar_days = @calendar.days
    @client.insert_events(calendar_days, result.id)
  end
  # Googleカレンダーからの予定取得用
  # def get_event
  # @client.get_event
  # redirect_to root_path, notice: '予定を取得しました'
  # end

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
end
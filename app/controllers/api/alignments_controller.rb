# frozen_string_literal: true

class Api::AllignmentsController < ActionController
  skip_before_action :check_logged_in, only: :create

  def create
    client = CalendarClient.new(current_user)
    client.create_event
    
    redirect_to root_path, notice: '書き込みテスト終了'
  end

  def delete
    client = CalendarClient.new(current_user)
    client.delete_calendar

    redirect_to root_path, notice: '削除しました'
  end

  def get_event
    client = CalendarClient.new(current_user)
    client.get_event
    redirect_to root_path, notice: '予定を取得しました'
  end

  def new
    client = CalendarClient.new(current_user)
    client.create_calendar
    redirect_to root_path, notice: '新しいカレンダーを作りました'
  end

  def batch
    client = CalendarClient.new(current_user)
    client.batch_test
    
    redirect_to root_path, notice: '書き込みテスト終了'
  end
end

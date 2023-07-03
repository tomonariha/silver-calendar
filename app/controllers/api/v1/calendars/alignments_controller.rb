# frozen_string_literal: true
  
module API
  module V1
    module Calendars
      class AlignmentsController < ApplicationController
        def create
          # resultにはGoogleカレンダーからのレスポンスが入る。
          # Googleカレンダーに新しく作ったカレンダーのIDを取得するための処理。
          calendar = set_calendar
          client = set_calendar_client
          @result = client.create_calendar(calendar)
          calendar_days = calendar.days
          client.insert_events(calendar_days, @result.id, set_working_times)
        end
      
        def destroy
          calendar = set_calendar
          client = set_calendar_client
          @result = client.delete_calendar(calendar)
        end
      
        def update
          # Googleカレンダーに追加したカレンダーを削除し新しくカレンダーを作り直す
          # 個別に日程の予定を更新するにはevent_idが必要で処理が冗長になるため
          calendar = set_calendar
          client = set_calendar_client
          client.delete_calendar(calendar)
          @result = client.create_calendar(calendar)
          calendar_days = calendar.days
          client.insert_events(calendar_days, @result.id, set_working_times)
        end
      
        private

        def set_calendar
          current_calendars.find_by(year: params[:calendar_year])
        end
      
        def set_calendar_client
          CalendarClient.new(current_user)
        end
      
        def set_working_times
          params
        end
      end
    end
  end
end

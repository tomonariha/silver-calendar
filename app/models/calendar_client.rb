# frozen_string_literal: true

class CalendarClient
  def initialize(user)
    google_client_id = ENV['GOOGLE_CLIENT_ID']
    google_client_secret = ENV['GOOGLE_CLIENT_SECRET']
    @service = Google::Apis::CalendarV3::CalendarService.new
    @user = user
    @client = Signet::OAuth2::Client.new(
      client_id: google_client_id,
      client_secret: google_client_secret,
      authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
      token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
      access_token: Rails.cache.read(user.uid),
      refresh_token: Rails.cache.read(user.uid + user.id.to_s),
      expires_at: Rails.cache.read("#{user.uid}expires_at")
    )
  end

  def insert_events(calendar_days, google_calendar_id)
    if calendar_days.empty?
      return
    end
    events = []
    calendar_days.map do |day|
      date = day.date
      event = Google::Apis::CalendarV3::Event.new(
        summary: "#{day.schedule}",
        start: Google::Apis::CalendarV3::EventDateTime.new(
          date: date
        ),
        end: Google::Apis::CalendarV3::EventDateTime.new(
          date: date
        ),
        description: "今日の予定"
      )
      events << event
    end

    authorize

    @service.batch do |service|
      events.each do |event|
        service.insert_event(google_calendar_id, event)
      end
    end
  end

  def delete_calendar(calendar)
    authorize
    @service.delete_calendar(calendar.google_calendar_id)
    calendar.update!(google_calendar_id: nil)
  end

  def get_event
    page_token = nil
    now = Time.now.iso8601
    authorize
    result = @service.list_events('primary')
    #result = @service.list_events('primary', 
     #                             single_events: true,
      #                            order_by: 'startTime',
       #                           time_min: now,
        #                          page_token: page_token,
         #                         fields: 'items(id,summary,start),next_page_token')
  end

  def create_calendar(calendar)
    new_calendar = Google::Apis::CalendarV3::Calendar.new(summary: "WDD #{calendar.year}年", descrition: 'テスト')
    authorize
    result = @service.insert_calendar(new_calendar)
    #GoogleカレンダーからのレスポンスでカレンダーIDを取得しDBへ保存
    calendar.update!(google_calendar_id: result.id)
    result
  end

  private

  def authorize
    refresh!
    @service.authorization = @client
  end

  def refresh!
    return unless @client.expired?

    @client.refresh!
    Rails.cache.write("#{@user.uid}expires_at", @client.expires_at)
    Rails.cache.write(@user.uid, @client.access_token)
  end

  def delete_calendar_id_from_cache
    Rails.cache.delete("#{@user.uid}calendar_id")
  end
end

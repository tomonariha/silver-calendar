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

  def create_event
    event = Google::Apis::CalendarV3::Event.new(
      summary: "summary",
      start: Google::Apis::CalendarV3::EventDateTime.new(
        date: Date.today
      ),
      end: Google::Apis::CalendarV3::EventDateTime.new(
        date: Date.today
      ),
      description: "description"
    )
    authorize
    @service.insert_event('primary', event)
  end

  def delete_calendar
    calendar_id = Rails.cache.read("#{@user.uid}calendar_id")
    authorize
    @service.delete_calendar(calendar_id)
    delete_calendar_id_from_cache
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

  def create_calendar
    calendar = Google::Apis::CalendarV3::Calendar.new(summary: '検証用', descrition: 'テスト')
    authorize
    result = @service.insert_calendar(calendar)
    Rails.cache.write("#{@user.uid}calendar_id", result.id)
  end

  def batch_test
    calendar_id = Rails.cache.read("#{@user.uid}calendar_id")
    events = []
    (1..100).map do |i|
      event = Google::Apis::CalendarV3::Event.new(
        summary: "batch_test",
        start: Google::Apis::CalendarV3::EventDateTime.new(
          date: Date.parse("2022-11-01") + i.day
        ),
        end: Google::Apis::CalendarV3::EventDateTime.new(
          date: Date.parse("2022-11-01") + i.day
        ),
        description: "description"
      )
      events << event
    end
    authorize
    @service.batch do |service|
      events.each do |event|
        service.insert_event(calendar_id, event)
      end
    end
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

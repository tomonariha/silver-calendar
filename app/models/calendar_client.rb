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

  def insert_events(calendar_days, google_calendar_id, working_times)
    return if calendar_days.empty?

    morning_start_at = format_time(working_times['morningStartHour'], working_times['morningStartMinit'])
    morning_end_at = format_time(working_times['morningEndHour'], working_times['morningEndMinit'])
    after_noon_start_at = format_time(working_times['afterNoonStartHour'], working_times['afterNoonStartMinit'])
    after_noon_end_at = format_time(working_times['afterNoonEndHour'], working_times['afterNoonEndMinit'])
    full_time_start_at = format_time(working_times['fullTimeStartHour'], working_times['fullTimeStartMinit'])
    full_time_end_at = format_time(working_times['fullTimeEndHour'], working_times['fullTimeEndMinit'])
    events = []
    calendar_days.map do |day|
      date = day.date.strftime('%Y-%m-%d')
      case day.schedule
      when 'full-time'
        schedule = '全日出勤'
        start_at = Time.zone.parse("#{date} #{full_time_start_at}")
        end_at = Time.zone.parse("#{date} #{full_time_end_at}")
      when 'morning'
        schedule = '午前出勤'
        start_at = Time.zone.parse("#{date} #{morning_start_at}")
        end_at = Time.zone.parse("#{date} #{morning_end_at}")
      when 'after-noon'
        schedule = '午後出勤'
        start_at = Time.zone.parse("#{date} #{after_noon_start_at}")
        end_at = Time.zone.parse("#{date} #{after_noon_end_at}")
      end
      event = Google::Apis::CalendarV3::Event.new(
        summary: schedule,
        start: Google::Apis::CalendarV3::EventDateTime.new(
          date_time: start_at.strftime('%Y-%m-%dT%H:%M:%S%z')
        ),
        end: Google::Apis::CalendarV3::EventDateTime.new(
          date_time: end_at.strftime('%Y-%m-%dT%H:%M:%S%z')
        )
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

  def create_calendar(calendar)
    new_calendar = Google::Apis::CalendarV3::Calendar.new(
      summary: "WDD #{calendar.year}年",
      time_zone: 'Asia/Tokyo',
      descrition: 'テスト'
    )
    authorize
    result = @service.insert_calendar(new_calendar)
    # GoogleカレンダーからのレスポンスでカレンダーIDを取得しDBへ保存
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

  def format_time(hour, minit)
    "#{hour.to_s.rjust(2, '0')}:#{minit.to_s.rjust(2, '0')}"
  end
end

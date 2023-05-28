# frozen_string_literal: true

require 'json'
require 'rails_helper'

RSpec.describe CalendarClient, type: :model do
  let!(:user) { FactoryBot.create(:user, uid: 100) }
  let!(:calendar) { FactoryBot.create(:calendar, user_id: user.id, google_calendar_id: 'google_calendar_id') }
  let!(:client) { CalendarClient.new(user) }

  before do
    # リフレッシュトークン更新
    stub_request(:post, 'https://accounts.google.com/o/oauth2/token')
    .to_return( status: 200,
      body: '{
        "access_token" : "access_token",
        "token_type" : "Bearer",
        "expires_in" : 3600,
        "refresh_token" : "refresh_token"
        }',
      headers: { 'Content-Type' => 'application/json'}
    )
    # Googleカレンダー新規作成
    stub_request(:post, 'https://www.googleapis.com/calendar/v3/calendars')
    .to_return( status: 200,
      body: '{
        "id": "google_calendar_id",
        "status": "confirmed"}',
      headers: { 'Content-Type' => 'application/json'}
    )
    # Googleカレンダーに予定の挿入
    stub_request(:post, 'https://www.googleapis.com/calendar/v3/calendars/google_calendar_id/events')
    .to_return( status: 200,
      body: '{
        "status": "confirmed"}',
      headers: { 'Content-Type' => 'application/json'}
    )
    # Googleカレンダー削除
    stub_request(:delete, 'https://www.googleapis.com/calendar/v3/calendars/google_calendar_id')
    .to_return( status: 200,
      body: '{
        "status": "confirmed"}',
      headers: { 'Content-Type' => 'application/json'}
    )
  end
  
  context 'with token refresh' do
    before do
      Rails.cache.write(user.uid, 'access_token')
      Rails.cache.write("#{user.uid}expires_at", 1_111_111_111)
      Rails.cache.write(user.uid + user.id.to_s, 'refresh_token')
    end

    it 'create calendar to google calendar' do
      client.create_calendar(calendar)
      expect(WebMock).to have_requested(:post, 'https://www.googleapis.com/calendar/v3/calendars')
    end

    it 'delete from google calendar' do
      client.delete_calendar(calendar)
      expect(WebMock).to have_requested(:delete, 'https://www.googleapis.com/calendar/v3/calendars/google_calendar_id')
    end

    after do
      Rails.cache.delete(user.uid)
      Rails.cache.delete("#{user.uid}expires_at")
      Rails.cache.delete(user.uid + user.id.to_s)
    end
  end
end

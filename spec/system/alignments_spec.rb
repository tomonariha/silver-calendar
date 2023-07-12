# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Calendars', type: :system do
  let!(:user) { FactoryBot.create(:user) }
  let!(:calendar) { FactoryBot.create(:calendar, user_id: user.id) }
  let!(:day) { FactoryBot.create(:day, calendar_id: calendar.id) }
  let!(:full_time) { FactoryBot.create(:day, :full_time, calendar_id: calendar.id) }
  let!(:setting) { FactoryBot.create(:setting, calendar_id: calendar.id) }
  OmniAuth.config.test_mode = true
  OmniAuth.config.silence_get_warning = true
  OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
                                                                       provider: 'google_oauth2',
                                                                       uid: '123545',
                                                                       credentials: {
                                                                         token: 'token',
                                                                         refresh_token: 'refresh_token',
                                                                         expires_at: Time.zone.now.to_i
                                                                       }
                                                                     })

  before do
    sign_in user
    visit calendar_path
    Rails.application.env_config['devise.mapping'] = Devise.mappings[:user]
    Rails.application.env_config['omniauth.auth'] = OmniAuth.config.mock_auth[:google_oauth2]
  end

  scenario 'google oauth log in', js: true do
    click_button '連携'
    find('.google-button').click
    click_button '連携'
    expect(page).to have_content('Google認証完了')
  end
end

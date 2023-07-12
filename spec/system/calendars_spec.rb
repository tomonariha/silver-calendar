# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Calendars', type: :system do
  let!(:user) { FactoryBot.create(:user) }
  let!(:calendar) { FactoryBot.create(:calendar, user_id: user.id) }
  let!(:day) { FactoryBot.create(:day, calendar_id: calendar.id) }
  let!(:full_time) { FactoryBot.create(:day, :full_time, calendar_id: calendar.id) }
  let!(:setting) { FactoryBot.create(:setting, calendar_id: calendar.id) }

  scenario 'user insert new schedule on day of calendar', js: true do
    sign_in user
    visit calendar_path
    select '2023', from: 'selected_calendar_year'
    select '1', from: 'selected_calendar_month'
    within '#day1' do
      click_button 'off'
      click_button 'fullTime'
      expect(find('.calendar__day-button')).to have_selector("img[alt='fullTime']")
    end
  end

  scenario 'user insert paid leave on day of calendar', js: true do
    sign_in user
    visit calendar_path
    select '2023', from: 'selected_calendar_year'
    select '1', from: 'selected_calendar_month'
    within '#day1' do
      click_button 'off'
      click_button 'paidleave'
    end

    within '#day2' do
      click_button 'fullTime'
      click_button 'paidleave'
    end

    expect(page).to have_content('2023年1月 合計:2 有給：2')
  end

  scenario 'user delete schedule on day of calendar', js: true do
    sign_in user
    visit calendar_path
    select '2023', from: 'selected_calendar_year'
    select '1', from: 'selected_calendar_month'
    within '#day2' do
      click_button 'fullTime'
      click_button 'none'
      expect(find('.calendar__day-button')).to_not have_selector("img[alt='fullTime']")
    end
  end

  scenario 'user move to selected year and month', js: true do
    sign_in user
    visit calendar_path
    select '2022', from: 'selected_calendar_year'
    select '12', from: 'selected_calendar_month'
    click_button '＞'
    expect(find('.calendar-nav__year')).to have_content('2023年1月')
  end

  scenario 'user delete calendar', js: true do
    sign_in user
    visit calendar_path
    select '2023', from: 'selected_calendar_year'
    select '1', from: 'selected_calendar_month'
    within '#day1' do
      expect(find('.calendar__day-button')).to have_selector("img[alt='off']")
    end
    expect(page).to have_content('2023-01-01 〜 2023-01-31')
    find('.delete-calendar').click
    click_button 'はい'
    within '#day1' do
      expect(find('.calendar__day-button')).to_not have_selector("img[alt='off']")
    end
    expect(page).to_not have_content('2023-01-01 〜 2023-01-31')
  end
end

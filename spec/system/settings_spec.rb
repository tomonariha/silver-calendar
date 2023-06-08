# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings', type: :system do
  let!(:user) { FactoryBot.create(:user) }
  let!(:calendar) { FactoryBot.create(:calendar, user_id: user.id) }
  let!(:day) { FactoryBot.create(:day, calendar_id: calendar.id) }
  let!(:day2) { FactoryBot.create(:day, :day2, calendar_id: calendar.id) }
  let!(:setting) { FactoryBot.create(:setting, calendar_id: calendar.id) }

  before do
    sign_in user
    visit calendar_path
  end

  scenario 'user create new setting', js: true do
    click_button '新しい条件を作る'
    within('#form') do
      select '2', from: 'start_month_select'
      select '1', from: 'start_day_select'
      select '2', from: 'end_month_select'
      select '28', from: 'end_day_select'
      uncheck 'check_specified_total_days'
      fill_in 'specified_total_days', with: 20
      click_button '＞'
      choose '全日出勤'
      click_button '＞'
      choose '全日出勤'
      click_button '＞'
      choose '全日出勤'
      click_button '＞'
      choose '全日出勤'
      click_button '＞'
      choose '全日出勤'
      click_button '新規作成'
    end
    expect(page).to have_content('2023-02-01 〜 2023-02-28')
  end

  scenario 'user update setting', js: true do
    expect(page).to have_content('2023-01-01 〜 2023-01-31')
    click_button '編集'
    within('#form') do
      select '3', from: 'start_month_select'
      select '3', from: 'start_day_select'
      select '3', from: 'end_month_select'
      select '30', from: 'end_day_select'
      click_button '変更'
    end
    expect(page).to have_content('2023-03-03 〜 2023-03-30')
    expect(page).to_not have_content('2023-01-01 〜 2023-01-31')
  end

  scenario 'user apply setting to calendar', js: true do
    click_button '適用'
    select '2023', from: 'selected_calendar_year'
    select '1', from: 'selected_calendar_month'
    within '#day3' do
      expect(find('.calendar__day-button')).to have_selector("img[alt='fullTime']")
    end
  end

  scenario 'user delete setting', js: true do
    expect(page).to have_content('2023-01-01 〜 2023-01-31')
    find('.delete-button').click
    click_button 'はい'
    expect(page).to_not have_content('2023-01-01 〜 2023-01-31')
  end
end

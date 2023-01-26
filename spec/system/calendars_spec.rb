# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Calendars', type: :system do
  let!(:user) { FactoryBot.create(:user) }
  let!(:calendar) { FactoryBot.create(:calendar, user_id: user.id) }
  let!(:day) { FactoryBot.create(:day, calendar_id: calendar.id) }
  let!(:setting) { FactoryBot.create(:setting, calendar_id: calendar.id) }

  before do
    sign_in user
    visit root_path
  end

  scenario 'user insert new schedule on day of calendar', js: true do
    within '#day1' do
      click_button
      click_button '●'
      expect(find('.calendar__day-body')).to have_content('●')
    end
  end

  scenario 'user delete schedule on day of calendar', js: true do
    within '#day2' do
      click_button
      click_button '指定なし'
      expect(find('.calendar__day-body')).to_not have_content('●')
    end
  end

  scenario 'user create new setting', js: true do
    click_button '条件の入力'
    within '#content' do
      click_button 'new'
      select '2', from: 'start_month_select'
      select '1', from: 'start_day_select'
      select '2', from: 'end_month_select'
      select '28', from: 'end_day_select'
      uncheck 'check_specified_total_days'
      fill_in 'specified_total_days', with: 20
      click_button '後'
      choose '全日出勤'
      click_button '後'
      choose '全日出勤'
      click_button '後'
      choose '全日出勤'
      click_button '後'
      choose '全日出勤'
      click_button '後'
      choose '全日出勤'
      click_button '新規作成'
      expect(page).to have_content('2023-02-01 〜 2023-02-28')
    end
  end

  scenario 'user delete setting', js: true do
    click_button '条件の入力'
    expect(page).to have_content('2023-01-01 〜 2023-01-31')
    click_button 'この条件を削除'
    expect(page).to_not have_content('2023-01-01 〜 2023-01-31')
  end

  scenario 'user apply setting to calendar', js: true do
    click_button '適用'
    within '#day3' do
      expect(find('.calendar__day-body')).to have_content('●')
    end
  end

  scenario 'user move to specified year and month', js: true do
    select '2022', from: 'specifiy_calendar_year'
    select '12', from: 'specifiy_calendar_month'
    click_button '後'
    expect(find('.calendar-nav__year--month')).to have_content('2023年1月')
  end
end

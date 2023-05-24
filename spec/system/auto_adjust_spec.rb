# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'AutoAdjust', type: :system do
  let!(:user) { FactoryBot.create(:user) }
  let!(:calendar) { FactoryBot.create(:calendar, user_id: user.id) }

  before do
    sign_in user
    visit calendar_path
    click_button '条件の入力'
    click_button '新しい条件を作る'
  end

  scenario 'total days is 150', js: true do
    within('#form') do
      select '1', from: 'start_month_select'
      select '1', from: 'start_day_select'
      select '12', from: 'end_month_select'
      select '31', from: 'end_day_select'
      uncheck 'check_specified_total_days'
      fill_in 'specified_total_days', with: 150
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
    click_button '適用'
    expect(page).to have_content('(現在の日数)150 / 150(必要日数)')
  end

  scenario 'total days is 2', js: true do
    within('#form') do
      select '1', from: 'start_month_select'
      select '3', from: 'start_day_select'
      select '1', from: 'end_month_select'
      select '4', from: 'end_day_select'
      uncheck 'check_specified_total_days'
      fill_in 'specified_total_days', with: 2
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
  
    click_button '適用'
    expect(page).to have_content('(現在の日数)2 / 2(必要日数)')
    within '#day3' do
      expect(find('.calendar__day-button')).to have_selector("img[alt='fullTime']")
    end
  
    within '#day4' do
      expect(find('.calendar__day-button')).to have_selector("img[alt='fullTime']")
    end
  end
end

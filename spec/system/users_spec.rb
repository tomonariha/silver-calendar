# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users', type: :system do
  let!(:user) { FactoryBot.create(:user) }

  scenario 'logged in user view calendar', js: true do
    sign_in user
    visit calendar_path
    expect(page).to have_content('カレンダーの作成')
  end

  scenario 'user not logged in view calendar', js: true do
    visit calendar_path
    expect(page).to_not have_content('カレンダーの作成')
  end

  scenario 'user log out', js: true do
    sign_in user
    visit calendar_path
    click_button 'ログアウト'
    visit calendar_path
    expect(page).to_not have_content('カレンダーの作成')
  end
end

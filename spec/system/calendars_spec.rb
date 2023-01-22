require 'rails_helper'

RSpec.describe "Calendars", type: :system do
  let(:user) { FactoryBot.create(:user) }
  
  before do
    sign_in :user
    visit root_path
  end

  scenario "user insert new schedule on day of calendar", js: true do

  end
end

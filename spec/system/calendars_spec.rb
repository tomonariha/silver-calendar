require 'rails_helper'

RSpec.describe "Calendars", type: :system do
  let(:user) { FactoryBot.create(:user) }

  before do
    sign_in user
    visit root_path
  end

  scenario "user insert new schedule on day of calendar", js: true do
    within "#day1" do
      click_button
      click_button "●"
      expect(find('.calendar__day-body')).to have_content("●")
    end
  end
end

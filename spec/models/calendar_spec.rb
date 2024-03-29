# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Calendar, type: :model do
  it 'is valid with a user_id, year' do
    expect(FactoryBot.create(:calendar)).to be_valid
  end

  it 'is invalid with invalid number in year' do
    calendar = FactoryBot.build(:calendar, year: 2101)
    calendar.valid?
    expect(calendar.errors[:year]).to include('2000年から2100年の間になるようにしてください')
  end

  it 'is invalid with that the same year exists' do
    calendar = FactoryBot.create(:calendar)
    new_calendar = FactoryBot.build(:calendar, user_id: calendar.user_id)
    new_calendar.valid?
    expect(new_calendar.errors[:year]).to include('はすでに存在します')
  end
end

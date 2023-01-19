# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Calendar, type: :model do
  it 'is valid with a user_id, year' do
    expect(FactoryBot.build(:calendar)).to be_valid
  end

  it 'is invalid without user_id' do
    calendar = Calendar.new(user_id: nil)
    calendar.valid?
    expect(calendar.errors[:user_id]).to include('を入力してください')
  end

  it 'is invalid without year' do
    calendar = Calendar.new(year: nil)
    calendar.valid?
    expect(calendar.errors[:year]).to include('を入力してください')
  end

  it 'is invalid with invalid number in year' do
    calendar = FactoryBot.build(:calendar, year: 2101)
    calendar.valid?
    expect(calendar.errors[:year]).to include('2000年から2100年の間になるようにしてください')
  end

  it 'is invalid with that the same year exists' do
    calendar = FactoryBot.build(:calendar)
    new_calendar = FactoryBot.build(:calendar)
    new_calendar.valid?
    expect(new_calendar.errors[:year]).to include('同じ年のカレンダーが既に存在しています')
  end
end

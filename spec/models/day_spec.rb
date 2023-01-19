# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Day, type: :model do
  it 'is valid with a calendar_id, date, schedule' do
    expect(FactoryBot.build(:day)).to be_valid
  end

  it 'is invalid without calendar_id' do
    day = Day.new(calendar_id: nil)
    day.valid?
    expect(day.errors[:calendar_id]).to include('を入力してください')
  end

  it 'is invalid without date' do
    day = Day.new(date: nil)
    day.valid?
    expect(day.errors[:date]).to include('を入力してください')
  end

  it 'is invalid a schedule that has invalid string' do
    day = Day.new(schedule: 'wrong schedule')
    day.valid?
    expect(day.errors[:schedule]).to include('無効な文字列です')
  end
end

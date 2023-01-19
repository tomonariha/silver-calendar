# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Setting, type: :model do
  it 'is valid with a calendar_id, period_start_at, period_end_at' do
    expect(FactoryBot.build(:setting)).to be_valid
  end

  it 'is invalid with periods overlaps' do
    setting = FactoryBot.build(:setting)
    another_setting = FactoryBot.build(:setting)
    setting.valid?
    expect(setting.errors[:calendar_id]).to include('他の条件の期間と重ならないようにしてください。')
  end

  it 'is invalid without calendar_id' do
    setting = Setting.new(calendar_id: nil)
    setting.valid?
    expect(setting.errors[:calendar_id]).to include('を入力してください')
  end

  it 'is invalid without period_start_at' do
    setting = Setting.new(period_start_at: nil)
    setting.valid?
    expect(setting.errors[:period_start_at]).to include('を入力してください')
  end

  it 'is invalid without period_end_at' do
    setting = Setting.new(period_end_at: nil)
    setting.valid?
    expect(setting.errors[:period_end_at]).to include('を入力してください')
  end

  it 'is invalid a period_start_at that is after period_end_at' do
    setting = Setting.new(period_start_at: '2023-1-31', period_end_at: '2023-1-1')
    setting.valid?
    expect(setting.errors[:period_end_at]).to include('開始日が終了日以前になるようにしてください。')
  end

  it 'is invalid a total_working_days that has more than the number of days in the period' do
    setting = FactoryBot.build(:setting, total_working_days: 366)
    expect(setting.errors[:schedule_of_sunday]).to include('勤務日数は０以上期間内の日数以下にしてください。')
  end

  it 'is invalid a schedule_of_sunday that has invalid string' do
    setting = Setting.new(schedule_of_sunday: 'wrong schedule')
    setting.valid?
    expect(setting.errors[:schedule_of_sunday]).to include('無効な文字列です')
  end
end

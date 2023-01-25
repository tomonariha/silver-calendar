# frozen_string_literal: true

FactoryBot.define do
  factory :day do
    date { Date.new(2023, 1, 2) }
    schedule { 'off' }
    association :calendar
  end
end

# frozen_string_literal: true

FactoryBot.define do
  factory :calendar do
    year { '2023' }
    association :user
  end
end

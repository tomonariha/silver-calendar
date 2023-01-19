FactoryBot.define do
  factory :day do
    date { "2023-1-1" }
    schedule { "off" }
    calendar
  end
end
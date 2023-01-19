FactoryBot.define do
  factory :setting do
    period_start_at { "2023-1-1" }
    period_end_at { "2023-12-31" }
    total_working_days { "180" }
    calendar
  end
end

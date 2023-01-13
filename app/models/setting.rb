# frozen_string_literal: true

class Setting < ApplicationRecord
  belongs_to :calendar, dependent: :destroy
end

# frozen_string_literal: true

class Calendar < ApplicationRecord
  belongs_to :user
  has_many :days, dependent: :destroy
  has_many :settings, dependent: :destroy
end

# frozen_string_literal: true

class Calendar < ApplicationRecord
  belongs_to :user
  has_many :days, dependent: :destroy
  has_many :settings, dependent: :destroy
  validates :year, presence: true, uniqueness: { scope: :user_id }
  validate :year_should_be_between_2000and2100

  private

  def year_should_be_between_2000and2100
    return unless year

    return unless (year < 2000) || (year > 2100)

    errors.add(:year, '2000年から2100年の間になるようにしてください')
  end
end

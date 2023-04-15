# frozen_string_literal: true

class Api::TimesController < ApplicationController
  def update
    user = current_user
    user.update!(time_params.transform_keys! {|key| key.underscore })
  end

  private

  def time_params
    params.require(:time).permit(
      :morningStartHour,
      :morningStartMinit,
      :morningEndHour,
      :morningEndMinit,
      :afterNoonStartHour,
      :afterNoonStartMinit,
      :afterNoonEndHour,
      :afterNoonEndMinit,
      :fullTimeStartHour,
      :fullTimeStartMinit,
      :fullTimeEndHour,
      :fullTimeEndMinit
    )
  end
end

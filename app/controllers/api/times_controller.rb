# frozen_string_literal: true

class Api::TimesController < ApplicationController
  def update
    user = current_user
    debugger
    user.time_params
    user.save!
  end

  private

  def time_params

  end
end

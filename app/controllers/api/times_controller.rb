# frozen_string_literal: true

class Api::TimesController < ApplicationController
  def update
    user = current_user
    debugger
    user.set_time_params(params)
    user.save!
  end
end

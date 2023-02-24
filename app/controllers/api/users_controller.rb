# frozen_string_literal: true

class Api::UsersController < ApplicationController
  def show
    user = current_user
    access_token = Rails.cache.read(user.uid)
    if access_token.nil?
      @authenticate = false
    else
      @authenticate = true
    end
  end
end

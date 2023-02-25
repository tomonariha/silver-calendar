# frozen_string_literal: true

class Api::UsersController < ApplicationController
  def show
    user = current_user
    access_token = Rails.cache.read(user.uid)
    @authenticate = if access_token.nil?
                      false
                    else
                      true
                    end
  end
end

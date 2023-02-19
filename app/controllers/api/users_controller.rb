# frozen_string_literal: true

class Api::UsersController < ApplicationController
  def show
    @user = current_user
  end
end

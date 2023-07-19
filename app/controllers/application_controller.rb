# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  protect_from_forgery
  include CalendarsHelper

  def after_sign_in_path_for(_resource)
    calendar_path
  end
end

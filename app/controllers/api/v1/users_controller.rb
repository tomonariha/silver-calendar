# frozen_string_literal: true

module API
  module V1
    class UsersController < ApplicationController
      def show
        access_token = Rails.cache.read(current_user.uid)
        @authenticate = !access_token.nil?
      end
    end
  end
end

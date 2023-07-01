# frozen_string_literal: true

module API
  module V1
    class UsersController < ApplicationController
      def show
        @user = current_user
        access_token = Rails.cache.read(@user.uid)
        @authenticate = if access_token.nil?
                          false
                        else
                          true
                        end
      end
    end
  end
end

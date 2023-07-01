# frozen_string_literal: true

module API
  module V1
    class TimesController < ApplicationController
      def update
        user = current_user
        user.update!(time_params.transform_keys!(&:underscore))
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
  end
end
    
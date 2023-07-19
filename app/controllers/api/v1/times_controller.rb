# frozen_string_literal: true

module API
  module V1
    class TimesController < ApplicationController
      def update
        current_user.update!(time_params.transform_keys!(&:underscore))
        head :no_content
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

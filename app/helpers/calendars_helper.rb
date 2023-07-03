# frozen_string_literal: true

module CalendarsHelper
  def current_calendars
    current_user.calendars
  end
end

# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'silver-calendar.com'
  layout 'mailer'
end

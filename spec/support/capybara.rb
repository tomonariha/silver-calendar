# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  Webdrivers::Chromedriver.required_version = '114.0.5735.90'
  config.before(:each, type: :system, js: true) do
    driven_by :selenium, using: :headless_chrome
  end
end

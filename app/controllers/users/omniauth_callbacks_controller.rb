# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    auth = request.env['omniauth.auth']
    if current_user
      user = current_user
      register_provider_uid(user, auth)
    else
      user = User.from_omniauth(auth)
    end

    user.store_credentials_in_cache(auth)

    if user.persisted?
      sign_in_and_redirect user, event: :authentication
    else
      redirect_to new_user_registration_url
    end
  end

  private

  def register_provider_uid(user, auth)
    user.uid = auth.uid
    user.provider = auth.provider
    user.save!
  end
end

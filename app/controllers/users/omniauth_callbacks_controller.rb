class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    callback_from(:google_oauth2)
  end

  private

  def callback_from(provider)
    provider = provider.to_s
    auth = request.env['omniauth.auth']
    @user = User.from_omniauth(auth)
    @user.store_credentials_in_cache(auth)
    if @user.persisted?
      flash[:notice] = I18n.t('devise.omniauth_callbacks.success', kind: provider.capitalize)
      sign_in_and_redirect @user, event: :authentication
    else
      session["devise.#{provider}_data"] = request.env['omniauth.auth']
      redirect_to new_user_registration_url
    end
  end
end

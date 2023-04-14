# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]
  has_many :calendars, dependent: :destroy

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
    end
  end

  def store_credentials_in_cache(auth)
    expires_at = auth.credentials.expires_at
    Rails.cache.write("#{uid}expires_at", expires_at)
    Rails.cache.write(uid, auth.credentials.token)
    Rails.cache.write(uid + id.to_s, auth.credentials.refresh_token)
  end

  def set_time_params(time_params)
    time_params[]
  end
end

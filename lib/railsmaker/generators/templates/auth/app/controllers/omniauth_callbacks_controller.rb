# frozen_string_literal: true

class OmniauthCallbacksController < ApplicationController
  def google_oauth2
    user = User.from_omniauth(request.env['omniauth.auth'])

    if user.persisted?
      sign_in user
      redirect_to demo_url, notice: 'Successfully signed in with Google!'
    else
      redirect_to sign_in_url, alert: 'Failed to sign in with Google.'
    end
  end

  def failure
    redirect_to sign_in_url, alert: 'Failed to sign in with Google.'
  end
end

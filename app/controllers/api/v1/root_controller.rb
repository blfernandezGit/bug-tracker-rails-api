class Api::V1::RootController < ApplicationController
  before_action :process_token
  before_action :authenticate_api_v1_user!
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  # Extract user id from passed jwt using jwt gem with error handling
  def process_token
    if request.headers['Authorization'].present?
      begin
        jwt_payload = JWT.decode(request.headers['Authorization'],
                                 Rails.application.secrets.secret_key_base).first
        @current_user_id = jwt_payload['id']
      rescue JWT::ExpiredSignature, JWT::VerificationError, JWT::DecodeError
        unauthorized
      end
    else
      unauthorized
    end
  end

  def unauthorized
    render json: {
      status: '401',
      errors: [
        {
          title: 'Unauthorized',
          messages: ['You need to sign in or sign up before continuing.']
        }
      ]
    }, status: :unauthorized
  end

  def not_found
    render json: {
      status: '404',
      errors: [
        {
          title: 'Not Found',
          messages: ['Page not found.']
        }
      ]
    }, status: :not_found
  end
end

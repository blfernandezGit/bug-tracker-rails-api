class ApplicationController < ActionController::API
    respond_to :json

    before_action :process_token

    # Override devise methods
    def authenticate_api_v1_user!(options = {})
        head :unauthorized unless signed_in?
    end

    def signed_in?
        @current_user_id.present?
    end

    def current_user
        @current_user ||= super || User.find(@current_user_id)
    end

    # Extract user id from passed jwt using jwt gem with error handling
    def process_token
        if request.headers['Authorization'].present?
            begin
                jwt_payload = JWT.decode(request.headers['Authorization'], Rails.application.secrets.secret_key_base).first
                @current_user_id = jwt_payload['id']
            rescue JWT::ExpiredSignature, JWT::VerificationError, JWT::DecodeError
                unauthorized
            end
        end
    end

    private

    def unauthorized
        render json: { 
            status: "401", 
            errors: {message:"You need to sign in or sign up before continuing." }
        }, status: :unauthorized
    end
end

class ApplicationController < ActionController::API
    respond_to :json

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
end

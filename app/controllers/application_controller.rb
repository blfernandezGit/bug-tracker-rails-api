class ApplicationController < ActionController::API
  respond_to :json

  # Override devise methods
  def authenticate_api_v1_admin!(_options = {})
    admin_unauthorized unless signed_in? && current_api_v1_user.is_admin
  end

  def authenticate_api_v1_user!(_options = {})
    unauthorized unless signed_in?
  end

  def signed_in?
    @current_user_id.present?
  end

  def current_api_v1_user
    @current_user ||= super || User.find(@current_user_id)
  end

  def authenticate_api_v2_admin!(_options = {})
    admin_unauthorized unless signed_in? && current_api_v2_user.is_admin
  end

  def authenticate_api_v2_user!(_options = {})
    unauthorized unless signed_in?
  end

  def current_api_v2_user
    @current_user ||= super || User.find(@current_user_id)
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

  def admin_unauthorized
    render json: {
      status: '401',
      errors: [
        {
          title: 'Unauthorized',
          messages: ['Sorry, you do not have enough permissions to access this page.']
        }
      ]
    }, status: :unauthorized
  end
end

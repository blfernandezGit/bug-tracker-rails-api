# frozen_string_literal: true

class Api::V2::Authorization::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  # POST /resource
  def create
    build_resource(sign_up_params)

    @user = resource

    if @user.save
      sign_up(resource_name, resource)
      @token = @user.generate_jwt
      response.set_header('Authorization', @token)
      render json: { data: {
        id: @user.id,
        email: @user.email,
        first_name: @user.first_name,
        last_name: @user.last_name,
        username: @user.username,
        is_admin: @user.is_admin,
        authToken: @token
      } }.merge!({
                   status: '200',
                   messages: ['User successfully signed up.']
                 }), status: :ok
    else
      unprocessable_entity(@user.errors.full_messages)
    end
  end

  private

  def sign_up_params
    params.permit(:email, :password, :password_confirmation, :first_name, :last_name, :username)
  end

  def unprocessable_entity(messages)
    render json: {
      status: '422',
      errors: [
        {
          title: 'Unprocessable Entity',
          messages: messages
        }
      ]
    }, status: :unprocessable_entity
  end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[first_name last_name username])
  end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end

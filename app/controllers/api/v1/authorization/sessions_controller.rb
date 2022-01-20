# frozen_string_literal: true

class Api::V1::Authorization::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # POST /resource/sign_in
  def create
    @user = User.find_by_email(sign_in_params[:email])
    if @user && @user.valid_password?(sign_in_params[:password])
      @token = @user.generate_jwt
      response.set_header('Authorization', @token)
      render json: { data: {
        email: @user.email,
        first_name: @user.first_name,
        last_name: @user.last_name,
        username: @user.username,
        authToken: @token
      } }.merge!({
                   status: '200',
                   messages: ['User successfully signed in.']
                 }), status: :ok
    elsif !@user
      unprocessable_entity('User is not registered.')
    else
      unprocessable_entity('Password is invalid.')
    end
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  private

  def sign_in_params
    params.permit(:email, :password)
  end

  def unprocessable_entity(messages)
    render json: {
      status: '422',
      errors: [
        {
          title: 'Unprocessable Entity',
          messages: [messages]
        }
      ]
    }, status: :unprocessable_entity
  end

  # protected

  # # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end

# frozen_string_literal: true

class Api::V1::Overrides::SessionsController < Devise::SessionsController
  before_action :configure_sign_in_params, only: [:create]

  # POST /resource/sign_in
  def create
    @user = User.find_by_email(sign_in_params[:email])
    if @user && @user.valid_password?(sign_in_params[:password])
      @token = @user.generate_jwt
      render json: { 
        status: "200", 
        email: @user.email, 
        userToken: @user.id, 
        authToken: @token 
      }, status: :ok
    elsif !@user
      unprocessable_entity( "User is not registered." )
    else
      unprocessable_entity( "Password is invalid." )
    end
  end

  private

  def sign_in_params
    params.permit(:email, :password)
  end

  def unprocessable_entity(messages)
    render json: { 
      status: "422", 
      errors: [
        {
          title: "Unprocessable Entity",
          messages: [ messages ]
        }
      ]
    }, status: :unprocessable_entity
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  end
end

class Api::V1::UsersController < Api::V1::RootController
  before_action :authenticate_api_v1_admin!, only: %i[create update destroy]
  before_action :set_user, only: %i[update destroy]

  def index
    @users = User.all
    if @users.count > 0
      render json: {
        status: '200',
        data: UserSerializer.new(@users).serializable_hash,
        messages: ['Users successfully retrieved.']
      }, status: :ok
    else
      render json: {
        status: '422',
        errors: [
          title: 'Unprocessable Entity',
          messages: ['No users found.']
        ]
      }, status: :unprocessable_entity
    end
  end

  def show
    @user = User.find_by(username: params[:username])
    if @user
      render json: {
        status: '200',
        data: UserSerializer.new(@user).serializable_hash,
        messages: ['User successfully retrieved.']
      }, status: :ok
    else
      render json: {
        status: '422',
        errors: [
          title: 'Unprocessable Entity',
          messages: ['User does not exist.']
        ]
      }, status: :unprocessable_entity
    end
  end

  def create
    @user = User.new(user_params)

    if @user.save
      @user.projects = Project.all if @user.is_admin
      render json: {
        status: '200',
        data: UserSerializer.new(@user).serializable_hash,
        messages: ['User successfully created.']
      }, status: :ok
    else
      render json: {
        status: '422',
        errors: [
          title: 'Unprocessable Entity',
          messages: @user.errors.full_messages
        ]
      }, status: :unprocessable_entity
    end
  end

  def update
    if @user.update(user_params)
      render json: {
        status: '200',
        data: UserSerializer.new(@user).serializable_hash,
        messages: ['User details successfully updated.']
      }, status: :ok
    else
      render json: {
        status: '422',
        errors: [
          title: 'Unprocessable Entity',
          messages: @user.errors.full_messages
        ]
      }, status: :unprocessable_entity
    end
  end

  def destroy
    if @user.destroy
      render json: {
        status: '200',
        deletedData: UserSerializer.new(@user).serializable_hash,
        messages: ['User successfully deleted.']
      }, status: :ok
    else
      render json: {
        status: '422',
        errors: [
          title: 'Unprocessable Entity',
          messages: @user.errors.full_messages
        ]
      }, status: :unprocessable_entity
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find_by(username: params[:username])
  end

  # Only allow a list of trusted parameters through.
  def user_params
    params.permit(:first_name, :last_name, :email, :username, :password, :is_admin)
  end
end

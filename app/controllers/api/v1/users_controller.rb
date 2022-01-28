class Api::V1::UsersController < Api::V1::RootController
  before_action :authenticate_api_v1_admin!, only: %i[create update destroy]
  before_action :set_user, only: %i[update destroy]

  def index
    @users = User.all.order(updated_at: :desc)
    if @users.count > 0
      render json: UserSerializer.new(@users).serializable_hash.merge!({
                                                                         status: '200',
                                                                         messages: ['Users successfully retrieved.']
                                                                       }), status: :ok
    else
      render json: {
        status: '422',
        errors: [
          title: 'Unprocessable Entity',
          messages: ['No users found.']
        ]
      }, status: :ok
    end
  end

  def show
    @user = User.find_by(username: params[:username])
    if @user
      render json: UserSerializer.new(@user).serializable_hash.merge!({
                                                                        status: '200',
                                                                        messages: ['User successfully retrieved.']
                                                                      }), status: :ok
    else
      render json: {
        status: '422',
        errors: [
          title: 'Unprocessable Entity',
          messages: ['User does not exist.']
        ]
      }, status: :ok
    end
  end

  def create
    @user = User.new(user_params)

    if @user.save
      @user.projects = Project.all if @user.is_admin
      render json: UserSerializer.new(@user).serializable_hash.merge!({
                                                                        status: '200',
                                                                        messages: ['User successfully created.']
                                                                      }), status: :ok
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
    if @user.username != 'suppadmin' && @user.username != 'blfernandez' && @user.update(user_params)
      render json: UserSerializer.new(@user).serializable_hash.merge!({
                                                                        status: '200',
                                                                        messages: ['User details successfully updated.']
                                                                      }), status: :ok
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
    if @user.username != 'suppadmin' && @user.username != 'blfernandez' && @user.destroy
      render json: { data: { username: @user.username, email: @user.email } }.merge!({
                                                                                       status: '200',
                                                                                       messages: ['User successfully deleted.']
                                                                                     }), status: :ok
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

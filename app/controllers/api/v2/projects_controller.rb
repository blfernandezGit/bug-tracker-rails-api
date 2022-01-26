class Api::V2::ProjectsController < Api::V2::RootController
  before_action :authenticate_api_v2_admin!, only: %i[create update destroy]
  before_action :set_project, only: %i[show update destroy get_project_users get_project_tickets]
  before_action :get_user, only: %i[get_current_user_projects]

  def index
    @projects = Project.all.order(updated_at: :desc)
    if @projects.count > 0
      render json: AllProjectsSerializer.new(@projects).serializable_hash.merge!({
                                                                               status: '200',
                                                                               messages: ['Projects successfully retrieved.']
                                                                             }), status: :ok
    else
      render json: {
        status: '422',
        errors: [
          title: 'Unprocessable Entity',
          messages: ['No projects found.']
        ]
      }, status: :ok
    end
  end

  def get_current_user_projects
    @projects = @user.projects.order(updated_at: :desc)
    if @projects.count > 0
      render json: ProjectSerializer.new(@projects).serializable_hash.merge!({
                                                                               status: '200',
                                                                               messages: ['Projects successfully retrieved.']
                                                                             }), status: :ok
    else
      render json: {
        status: '422',
        errors: [
          title: 'Unprocessable Entity',
          messages: ['No projects found.']
        ]
      }, status: :ok
    end
  end

  def get_project_users
    if @project.users.count > 0
      render json: ProjectUsersSerializer.new(@project).serializable_hash.merge!({
                                                                               status: '200',
                                                                               messages: ['Projects successfully retrieved.']
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

  def get_project_tickets
    if @project.tickets.count > 0
      render json: ProjectTicketsSerializer.new(@project).serializable_hash.merge!({
                                                                               status: '200',
                                                                               messages: ['Projects successfully retrieved.']
                                                                             }), status: :ok
    else
      render json: {
        status: '422',
        errors: [
          title: 'Unprocessable Entity',
          messages: ['No tickets found.']
        ]
      }, status: :ok
    end
  end

  def show
    if @project
      render json: ProjectSerializer.new(@project).serializable_hash.merge!({
                                                                              status: '200',
                                                                              messages: ['Project successfully retrieved.']
                                                                            }), status: :ok
    else
      render json: {
        status: '422',
        errors: [
          title: 'Unprocessable Entity',
          messages: ['Project does not exist.']
        ]
      }, status: :ok
    end
  end

  def create
    @project = Project.new(project_params)

    @project.code = @project.name.parameterize if @project.name # make url-friendly code from name

    if @project.save
      @admins = User.admins
      @admins.each do |admin|
        admin.projects.push(@project)
      end
      render json: ProjectSerializer.new(@project).serializable_hash.merge!({
                                                                              status: '200',
                                                                              messages: ['Project successfully created.']
                                                                            }), status: :ok
    else
      render json: {
        status: '422',
        errors: [
          title: 'Unprocessable Entity',
          messages: @project.errors.full_messages
        ]
      }, status: :unprocessable_entity
    end
  end

  def update
    project_params_updated = project_params
    project_params_updated[:code] = project_params_updated[:name].parameterize if project_params_updated[:name]

    if @project.update(project_params_updated)
      render json: ProjectSerializer.new(@project).serializable_hash.merge!({
                                                                              status: '200',
                                                                              messages: ['Project successfully updated.']
                                                                            }), status: :ok
    else
      render json: {
        status: '422',
        errors: [
          title: 'Unprocessable Entity',
          messages: @project.errors.full_messages
        ]
      }, status: :unprocessable_entity
    end
  end

  def destroy
    if @project.destroy
      render json: { data: { code: @project.code, name: @project.name } }.merge!({
                                                                                   status: '200',
                                                                                   messages: ['Project successfully deleted.']
                                                                                 }), status: :ok
    else
      render json: {
        status: '422',
        errors: [
          title: 'Unprocessable Entity',
          messages: @project.errors.full_messages
        ]
      }, status: :unprocessable_entity
    end
  end

  private

  def get_user
    @user = User.find(current_api_v2_user.id)
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_project
    @project = Project.find_by(code: params[:code])
  end

  # Only allow a list of trusted parameters through.
  def project_params
    params.permit(:name, :code, :description, :is_active)
  end
end

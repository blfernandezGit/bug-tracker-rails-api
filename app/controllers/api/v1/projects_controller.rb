class Api::V1::ProjectsController < Api::V1::RootController
    before_action :authenticate_api_v1_admin!, only: [:create, :update, :destroy]
    before_action :set_project, only: [:update, :destroy]

  def index
    @projects = Project.all
    if @projects.count > 0
      render json: {
        status: '200',
        data: ProjectSerializer.new(@projects).serializable_hash,
        messages: [ 'Projects successfully retrieved.' ]
      }, status: :ok
    else
      render json: {
        status: '422',
        errors: [
            title: 'Unprocessable Entity',
            messages: [ 'No projects found.' ]
        ]    
      }, status: :unprocessable_entity
    end
  end

  def show
    @project = Project.find_by(code: params[:code])
    if @project
      render json: {
        status: '200',
        data: ProjectSerializer.new(@project).serializable_hash,
        messages: [ 'Project successfully retrieved.' ]
      }, status: :ok
    else
      render json: {
        status: '422',
        errors: [
            title: 'Unprocessable Entity',
            messages: [ 'Project does not exist.' ]
        ]    
      }, status: :unprocessable_entity
    end
  end

  def create
    @project = Project.new(project_params)

    @project.code = @project.name.parameterize unless !@project.name # make url-friendly code from name

    if @project.save
        render json: {
            status: '200',
            data: ProjectSerializer.new(@project).serializable_hash,
            messages: [ 'Project successfully created.' ]
        }, status: :ok
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
    if @project.update(project_params)
        render json: {
            status: '200',
            data: ProjectSerializer.new(@project).serializable_hash,
            messages: [ 'Project successfully updated.' ]
        }, status: :ok
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
      render json: {
        status: '200',
        deletedData: ProjectSerializer.new(@project).serializable_hash,
        messages: [ 'Project successfully deleted.' ]
      }, status: :ok
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
  # Use callbacks to share common setup or constraints between actions.
  def set_project
    @project = Project.find_by(code: params[:code])
  end

  # Only allow a list of trusted parameters through.
  def project_params
    params.permit(:name, :code, :description, :is_active)
  end
end

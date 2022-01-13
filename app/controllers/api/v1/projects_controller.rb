class Api::V1::ProjectsController < Api::V1::RootController
    before_action :authenticate_api_v1_admin!, only: [:create, :update, :destroy]
    before_action :set_project, only: [:update, :destroy]
  def index
    projects = Project.all
    render json: ProjectSerializer.new(projects).serializable_hash.to_json
  end

  def show
    project = Project.find_by(code: params[:code])
    render json: ProjectSerializer.new(project).serializable_hash.to_json
  end

  def create
    @project = Project.new(project_params)

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

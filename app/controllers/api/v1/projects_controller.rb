class Api::V1::ProjectsController < Api::V1::RootController
  def index
    projects = Project.all

    render json: ProjectSerializer.new(projects).serializable_hash.to_json
  end

  def show
    project = Project.find_by(code: params[:code])
    render json: ProjectSerializer.new(project).serializable_hash.to_json
  end
end

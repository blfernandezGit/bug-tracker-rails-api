class Api::V1::ProjectMembershipsController < Api::V1::RootController
    require 'json'
    before_action :authenticate_api_v1_admin!

    def update_user_projects
        if project_membership_params[:user_id] && project_membership_params[:project_ids]
            @user = User.find(project_membership_params[:user_id])
            if !@user.is_admin
                @project_ids = JSON.parse(project_membership_params[:project_ids])
                @user_projects = @user.projects

                @project_ids.each do |project_id|
                    @project = Project.find(project_id)
                    @user_projects.push(@project)
                end

                @user.projects = @user_projects.uniq

                render json: {
                    status: '200',
                    data: {
                        user_id: @user.id,
                        project_ids: @user.projects.ids
                    },messages: [ 'User successfully added to projects.' ]
                }, status: :ok
            else
                render json: {
                    status: '422',
                    errors: [
                        title: 'Unprocessable Entity',
                        messages: [ 'Not allowed.' ]
                    ]    
                }, status: :unprocessable_entity
            end
        else
            render json: {
                status: '422',
                errors: [
                    title: 'Unprocessable Entity',
                    messages: [ 'Not allowed.' ]
                ]    
            }, status: :unprocessable_entity
        end
    end

    def update_project_users
        if project_membership_params[:project_id] && project_membership_params[:user_ids]
            @project = Project.find(project_membership_params[:project_id])
            @user_ids = JSON.parse(project_membership_params[:user_ids])
            @project_users = @project.users

            @user_ids.each do |user_id|
                @user = User.find(user_id)
                @project_users.push(@user)
            end

            @project.users = @project_users.push(User.where(is_admin: true)).uniq

            render json: {
                status: '200',
                data: {
                    project_id: @project.id,
                    user_ids: @project.users.ids
                }, messages: [ 'Users successfully added to Project.' ]
            }, status: :ok
        else
            render json: {
                status: '422',
                errors: [
                    title: 'Unprocessable Entity',
                    messages: [ 'Not allowed.' ]
                ]    
            }, status: :unprocessable_entity
        end
    end

    private

    # Only allow a list of trusted parameters through.
    def project_membership_params
        params.permit(:user_id, :project_id, :user_ids, :project_ids)
    end
end

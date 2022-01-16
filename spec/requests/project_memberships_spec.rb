require 'rails_helper'

RSpec.describe "ProjectMemberships", type: :request do
  before(:all) do
    @user = create(:user)
    @user2 = create(:user)
    @user3 = create(:user)
    @project = create(:project)
    @project.update(code: @project.name.parameterize)
    @project2 = create(:project)
    @project2.update(code: @project2.name.parameterize)
    @project3 = create(:project)
    @project3.update(code: @project3.name.parameterize)
  end

  context 'Project membership requests as Admin' do
    before(:all) do
        @admin = create(:user, :admin)
        @login_params = {
            email: @admin.email,
            password: @admin.password
        }
        post api_v1_user_session_url, params: @login_params
        @headers = {
            "Authorization": response.headers["Authorization"]
        }
    end
    
    describe "Add projects to user" do
      let(:valid_attributes) {
        {
          user_id: @user.id,
          project_ids: [@project.id,@project2.id].to_json
        }
      }
      
      before(:example) { post api_v1_update_user_projects_url, params: valid_attributes, headers: @headers}

      it "renders a successful response" do
        expect(response.status).to eq(200)
      end

      it "adds specified projects to user" do
        expect(@user.projects.count).to eq(2)
        expect(@user.projects.to_json).to include(@project.id)
        expect(@user.projects.to_json).to include(@project2.id)
        expect(@user.projects.to_json).to_not include(@project3.id)
      end
    end

    describe "Add users to a project" do
      let(:valid_attributes) {
        {
          project_id: @project.id,
          user_ids: [@user.id,@user2.id].to_json
        }
      }

      before(:example) { post api_v1_update_project_users_url, params: valid_attributes, headers: @headers}

      it "renders a successful response" do
        expect(response.status).to eq(200)
      end

      it "adds specified projects to user" do
        expect(@project.users.count).to eq(3)
        expect(@project.users.to_json).to include(@admin.id)
        expect(@project.users.to_json).to include(@user.id)
        expect(@project.users.to_json).to include(@user2.id)
        expect(@project.users.to_json).to_not include(@user3.id)
      end
    end
  end

  context 'Project membership requests as Client' do
    before(:all) do
        @client = create(:user)
        @login_params = {
            email: @client.email,
            password: @client.password
        }
        post api_v1_user_session_url, params: @login_params
        @headers = {
            "Authorization": response.headers["Authorization"]
        }
    end
    
    describe "Add projects to user" do
      let(:valid_attributes) {
        {
          user_id: @user.id,
          project_ids: [@project.id,@project2.id].to_json
        }
      }
      
      before(:example) { post api_v1_update_user_projects_url, params: valid_attributes, headers: @headers}

      it "is unauthorized" do
        expect(response.status).to eq(401)
      end
    end

    describe "Add users to a project" do
      let(:valid_attributes) {
        {
          project_id: @project.id,
          user_ids: [@user.id,@user2.id].to_json
        }
      }

      before(:example) { post api_v1_update_project_users_url, params: valid_attributes, headers: @headers}

      it "is unauthorized" do
        expect(response.status).to eq(401)
      end
    end
  end
end

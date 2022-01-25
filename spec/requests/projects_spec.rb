require 'rails_helper'

RSpec.describe 'Projects API Test', type: :request do
  before(:all) do
    @project = create(:project)
    @project.update(code: @project.name.parameterize)
    @project2 = create(:project)
    @project2.update(code: @project2.name.parameterize)
    @admin2 = create(:user, :admin)
    @user2 = create(:user)
  end

  let(:valid_attributes) do
    {
      name: 'ValidProjectName',
      description: 'ValidProjectDescription'
    }
  end

  let(:invalid_attributes_1) do
    {
      name: nil,
      description: 'ValidProjectDescription'
    }
  end

  let(:invalid_attributes_2) do
    {
      name: @project.code,
      description: 'ValidProjectDescription',
      code: @project.code
    }
  end

  context 'Project requests as Admin' do
    before(:all) do
      @admin = create(:user, :admin)
      @login_params = {
        email: @admin.email,
        password: @admin.password
      }
      post api_v1_user_session_url, params: @login_params
      @headers = {
        "Authorization": response.headers['Authorization']
      }
    end

    describe 'Get all projects: GET /index' do
      before(:example) do
        get api_v1_projects_url, headers: @headers
      end

      it 'renders a successful response' do
        expect(response.status).to eq(200)
      end

      it 'contains expected project attributes' do
        json_response_data = JSON.parse(response.body)['data'][0]
        attributes = json_response_data['attributes']
        expect(attributes.keys).to match_array(%w[code name description is_active last_ticket_no created_at updated_at
                                                  tickets users])
      end

      it 'contains all projects' do
        expect(response.body).to include(@project.name.to_s)
        expect(response.body).to include(@project2.name.to_s)
      end
    end

    describe 'Get current user projects: GET /get_current_user_projects' do
      before(:example) do
        create(:project_membership, user: @admin, project: @project)
        get api_v1_get_current_user_projects_url, headers: @headers
      end

      it 'renders a successful response' do
        expect(response.status).to eq(200)
      end

      it 'contains expected project attributes' do
        json_response_data = JSON.parse(response.body)['data'][0]
        attributes = json_response_data['attributes']
        expect(attributes.keys).to match_array(%w[code name description is_active last_ticket_no created_at updated_at
                                                  tickets users])
      end

      it 'contains all projects' do
        expect(response.body).to include(@project.name.to_s)
        expect(response.body).to_not include(@project2.name.to_s)
      end
    end

    describe 'View a specific project: GET /show' do
      context 'the project exists' do
        before(:example) do
          get api_v1_project_url(@project.code), headers: @headers
        end

        it 'renders a successful response' do
          expect(response.status).to eq(200)
        end

        it 'contains expected project attributes' do
          json_response_data = JSON.parse(response.body)['data']
          attributes = json_response_data['attributes']
          expect(attributes.keys).to match_array(%w[code name description is_active
                                                    last_ticket_no created_at updated_at tickets users])
          expect(response.body).to include('users')

          expect(response.body).to include('tickets')
        end

        it 'contains specific project' do
          expect(response.body).to include(@project.name.to_s)
        end
      end

      context 'the project does not exist' do
        before(:example) do
          get '/api/v1/projects/dne-code', headers: @headers
        end

        it 'throws an error' do
          expect(response.body).to include('errors')
          expect(response.status).to eq(200)
        end
      end
    end

    describe 'Admin user creates a new project: POST /create' do
      context 'valid attributes' do
        it 'creates a new project' do
          expect do
            post api_v1_projects_url, params: valid_attributes, headers: @headers
          end.to change(Project.all, :count).by(1)
          expect(response.status).to eq(200)
        end

        it 'adds project membership for all admins' do
          post api_v1_projects_url, params: valid_attributes, headers: @headers
          @new_project = Project.find_by(name: valid_attributes[:name])
          expect(@admin2.projects.to_json).to include(@new_project.id)
          expect(@user2.projects.to_json).to_not include(@new_project.id)
        end
      end

      context 'invalid attributes' do
        it 'throws an error when no name' do
          expect do
            post api_v1_projects_url, params: invalid_attributes_1, headers: @headers
          end.to change(Project.all, :count).by(0)
          expect(response.body).to include('errors')
          expect(response.status).to eq(422)
        end

        it 'throws an error when code is not unique' do
          expect do
            post api_v1_projects_url, params: invalid_attributes_2, headers: @headers
          end.to change(Project.all, :count).by(0)
          expect(response.body).to include('errors')
          expect(response.status).to eq(422)
        end
      end
    end

    describe 'Admin user updates a project: PATCH /update' do
      let(:new_attributes) do
        {
          name: 'ValidProjectNameUpdated',
          description: 'ValidProjectDescriptionUpdated'
        }
      end

      context 'valid attributes' do
        before(:example) do
          patch api_v1_project_url(@project.code), params: new_attributes, headers: @headers
        end

        it 'updates a project' do
          expect(Project.find(@project.id).name).to eq(new_attributes[:name])
          expect(Project.find(@project.id).description).to eq(new_attributes[:description])
          expect(response.status).to eq(200)
        end
      end

      context 'invalid attributes' do
        it 'throws an error when no name' do
          patch api_v1_project_url(@project.code), params: invalid_attributes_1, headers: @headers
          expect(@project.name).to_not eq(invalid_attributes_1[:name])
          expect(@project.description).to_not eq(invalid_attributes_1[:description])
          expect(response.body).to include('errors')
          expect(response.status).to eq(422)
        end

        it 'throws an error when code is not unique' do
          patch api_v1_project_url(@project2.code), params: invalid_attributes_2, headers: @headers
          expect(@project2.name).to_not eq(invalid_attributes_2[:name])
          expect(@project2.description).to_not eq(invalid_attributes_2[:description])
          expect(response.body).to include('errors')
          expect(response.status).to eq(422)
        end
      end
    end

    describe 'Admin user deletes a project: DELETE /destroy' do
      it 'deletes a project' do
        expect do
          delete api_v1_project_url(@project.code), headers: @headers
        end.to change(Project.all, :count).by(-1)
        expect(response.status).to eq(200)
      end
    end
  end

  context 'Project requests as Client' do
    before(:all) do
      @user = create(:user)
      @login_params = {
        email: @user.email,
        password: @user.password
      }
      post api_v1_user_session_url, params: @login_params
      @headers = {
        "Authorization": response.headers['Authorization']
      }
    end

    describe 'Get all projects: GET /index' do
      before(:example) do
        get api_v1_projects_url, headers: @headers
      end

      it 'renders a successful response' do
        expect(response.status).to eq(200)
      end

      it 'contains expected project attributes' do
        json_response_data = JSON.parse(response.body)['data'][0]
        attributes = json_response_data['attributes']
        expect(attributes.keys).to match_array(%w[code name description is_active last_ticket_no created_at updated_at
                                                  tickets users])
        expect(response.body).to include('users')

        expect(response.body).to include('tickets')
      end

      it 'contains all projects' do
        expect(response.body).to include(@project.name.to_s)
      end
    end

    describe 'View a specific project: GET /show' do
      context 'the project exists' do
        before(:example) do
          get api_v1_project_url(@project.code), headers: @headers
        end

        it 'renders a successful response' do
          expect(response.status).to eq(200)
        end

        it 'contains expected project attributes' do
          json_response_data = JSON.parse(response.body)['data']
          attributes = json_response_data['attributes']
          expect(attributes.keys).to match_array(%w[code name description is_active
                                                    last_ticket_no created_at updated_at tickets users])
          expect(response.body).to include('users')

          expect(response.body).to include('tickets')
        end

        it 'contains specific project' do
          expect(response.body).to include(@project.name.to_s)
        end
      end

      context 'the project does not exist' do
        before(:example) do
          get '/api/v1/projects/dne-code', headers: @headers
        end

        it 'throws an error' do
          expect(response.body).to include('errors')
          expect(response.status).to eq(200)
        end
      end
    end

    describe 'Client tries to create a new project: POST /create' do
      context 'valid attributes' do
        it 'is unauthorized' do
          expect do
            post api_v1_projects_url, params: valid_attributes, headers: @headers
          end.to change(Project.all, :count).by(0)
          expect(response.status).to eq(401)
        end
      end

      context 'invalid attributes' do
        it 'is unauthorized' do
          expect do
            post api_v1_projects_url, params: invalid_attributes_1, headers: @headers
          end.to change(Project.all, :count).by(0)
          expect(response.status).to eq(401)
        end
      end
    end

    describe 'Client tries to update a project: PATCH /update' do
      let(:new_attributes) do
        {
          name: 'ValidProjectNameUpdated',
          description: 'ValidProjectDescriptionUpdated'
        }
      end

      context 'valid attributes' do
        before(:example) do
          patch api_v1_project_url(@project.code), params: new_attributes, headers: @headers
        end

        it 'is unauthorized' do
          expect(@project.name).to_not eq(new_attributes[:name])
          expect(@project.description).to_not eq(new_attributes[:description])
          expect(response.status).to eq(401)
        end
      end

      context 'invalid attributes' do
        before(:example) do
          patch api_v1_project_url(@project.code), params: invalid_attributes_1, headers: @headers
        end

        it 'is unauthorized' do
          expect(@project.name).to_not eq(invalid_attributes_1[:name])
          expect(@project.description).to_not eq(invalid_attributes_1[:description])
          expect(response.status).to eq(401)
        end
      end
    end

    describe 'Client tries to delete a project: DELETE /destroy' do
      it 'is unauthorized' do
        expect do
          delete api_v1_project_url(@project.code), headers: @headers
        end.to change(Project.all, :count).by(0)
        expect(response.status).to eq(401)
      end
    end
  end
end

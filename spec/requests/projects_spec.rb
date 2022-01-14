require 'rails_helper'

#TODO: how to handle validation errors (uniqueness)

RSpec.describe 'Projects API Test', type: :request do
    before(:all) do
        @project = create(:project)
    end

    let(:valid_attributes) {
        {
            name: 'ValidProjectName',
            description: 'ValidProjectDescription'
        }
    }

    let(:invalid_attributes) {
        {
            name: nil,
            description: 'ValidProjectDescription'
        }
    }
    
    context 'Project requests as Admin' do
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

        describe 'Get all projects: GET /index' do
            before(:example) { 
                get api_v1_projects_url, headers: @headers
            }

            it "renders a successful response" do
                expect(response.status).to eq(200)
            end

            it "contains expected project attributes" do
                json_response_data = JSON.parse(response.body)['data']['data'][0]
                attributes = json_response_data['attributes']
                expect(attributes.keys).to match_array(["code", "name", "description", "is_active"])
            end

            it "contains all projects" do
                expect(response.body).to include(@project.name.to_s)
            end
        end

        describe 'View a specific project: GET /show' do
            context "the project exists" do
                before(:example) { 
                    get api_v1_project_url(@project.code), headers: @headers
                }

                it "renders a successful response" do
                    expect(response.status).to eq(200)
                end

                it "contains expected project attributes" do
                    json_response_data = JSON.parse(response.body)['data']['data']
                    attributes = json_response_data['attributes']
                    expect(attributes.keys).to match_array(["code", "name", "description", "is_active"])
                    expect(response.body).to include('users')
                    expect(response.body).to include('project_memberships')
                    expect(response.body).to include('tickets')
                end

                it "contains specific project" do
                    expect(response.body).to include(@project.name.to_s)
                end
            end

            context "the project does not exist" do
                before(:example) { 
                    get '/api/v1/projects/dne-code', headers: @headers
                }

                it 'throws an error' do
                    expect(response.body).to include('errors')
                    expect(response.status).to eq(422)
                end
            end
        end

        describe 'Admin user creates a new project: POST /create' do
            context 'valid attributes' do
                it "creates a new project" do
                    expect { 
                        post api_v1_projects_url, params: valid_attributes, headers: @headers
                    }.to change(Project.all, :count).by(1)
                    expect(response.status).to eq(200)
                end
            end

            context 'invalid attributes' do
                it "throws an error" do
                    expect { 
                        post api_v1_projects_url, params: invalid_attributes, headers: @headers
                    }.to change(Project.all, :count).by(0)
                    expect(response.body).to include('errors')
                    expect(response.status).to eq(422)
                end
            end
        end

        describe 'Admin user updates a project: PATCH /update' do
            let(:new_attributes) {
                {
                    name: 'ValidProjectNameUpdated',
                    description: 'ValidProjectDescriptionUpdated'
                }
            }

            context 'valid attributes' do
                before(:example) {
                    patch api_v1_project_url(@project.code), params: new_attributes, headers: @headers
                }

                it "updates a project" do
                    expect(Project.find(@project.id).name).to eq(new_attributes[:name])
                    expect(Project.find(@project.id).description).to eq(new_attributes[:description])
                    expect(response.status).to eq(200)
                end
            end

            context 'invalid attributes' do
                before(:example) {
                    patch api_v1_project_url(@project.code), params: invalid_attributes, headers: @headers
                }

                it "throws an error" do
                    expect(@project.name).to_not eq(invalid_attributes[:name])
                    expect(@project.description).to_not eq(invalid_attributes[:description])
                    expect(response.body).to include('errors')
                    expect(response.status).to eq(422)
                end
            end
        end

        describe 'Admin user deletes a project: DELETE /destroy' do
            it "deletes a project" do
                expect { 
                    delete api_v1_project_url(@project.code), headers: @headers
                }.to change(Project.all, :count).by(-1)
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
                "Authorization": response.headers["Authorization"]
            }
        end

        describe 'Get all projects: GET /index' do
            before(:example) { 
                get api_v1_projects_url, headers: @headers
            }

            it "renders a successful response" do
                expect(response.status).to eq(200)
            end

            it "contains expected project attributes" do
                json_response_data = JSON.parse(response.body)['data']['data'][0]
                attributes = json_response_data['attributes']
                expect(attributes.keys).to match_array(["code", "name", "description", "is_active"])
                expect(response.body).to include('users')
                expect(response.body).to include('project_memberships')
                expect(response.body).to include('tickets')
            end

            it "contains all projects" do
                expect(response.body).to include(@project.name.to_s)
            end
        end

        describe 'View a specific project: GET /show' do
            context "the project exists" do
                before(:example) { 
                    get api_v1_project_url(@project.code), headers: @headers
                }

                it "renders a successful response" do
                    expect(response.status).to eq(200)
                end

                it "contains expected project attributes" do
                    json_response_data = JSON.parse(response.body)['data']['data']
                    attributes = json_response_data['attributes']
                    expect(attributes.keys).to match_array(["code", "name", "description", "is_active"])
                    expect(response.body).to include('users')
                    expect(response.body).to include('project_memberships')
                    expect(response.body).to include('tickets')
                end

                it "contains specific project" do
                    expect(response.body).to include(@project.name.to_s)
                end
            end

            context "the project does not exist" do
                before(:example) { 
                    get '/api/v1/projects/dne-code', headers: @headers
                }

                it 'throws an error' do
                    expect(response.body).to include('errors')
                    expect(response.status).to eq(422)
                end
            end
        end

        describe 'Client tries to create a new project: POST /create' do
            context 'valid attributes' do
                it "is unauthorized" do
                    expect { 
                        post api_v1_projects_url, params: valid_attributes, headers: @headers
                    }.to change(Project.all, :count).by(0)
                    expect(response.status).to eq(401)
                end
            end

            context 'invalid attributes' do
                it "is unauthorized" do
                    expect { 
                        post api_v1_projects_url, params: invalid_attributes, headers: @headers
                    }.to change(Project.all, :count).by(0)
                    expect(response.status).to eq(401)
                end
            end
        end

        describe 'Client tries to update a project: PATCH /update' do
            let(:new_attributes) {
                {
                    name: 'ValidProjectNameUpdated',
                    description: 'ValidProjectDescriptionUpdated'
                }
            }

            context 'valid attributes' do
                before(:example) {
                    patch api_v1_project_url(@project.code), params: new_attributes, headers: @headers
                }

                it "is unauthorized" do
                    expect(@project.name).to_not eq(new_attributes[:name])
                    expect(@project.description).to_not eq(new_attributes[:description])
                    expect(response.status).to eq(401)
                end
            end

            context 'invalid attributes' do
                before(:example) {
                    patch api_v1_project_url(@project.code), params: invalid_attributes, headers: @headers
                }

                it "is unauthorized" do
                    expect(@project.name).to_not eq(invalid_attributes[:name])
                    expect(@project.description).to_not eq(invalid_attributes[:description])
                    expect(response.status).to eq(401)
                end
            end
        end

        describe 'Client tries to delete a project: DELETE /destroy' do
            it "is unauthorized" do
                expect { 
                    delete api_v1_project_url(@project.code), headers: @headers
                }.to change(Project.all, :count).by(0)
                expect(response.status).to eq(401)
            end
        end
    end
end
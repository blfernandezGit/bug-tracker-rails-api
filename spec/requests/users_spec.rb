require 'rails_helper'

RSpec.describe 'Users API Test', type: :request do
  before(:all) do
    @user = create(:user)
    @project = create(:project)
  end

  let(:valid_attributes) do
    {
      first_name: 'ValidFirstName',
      last_name: 'ValidLastName',
      email: 'valid_email@example.com',
      username: 'validusername',
      password: 'P@ssw0rd'
    }
  end

  let(:valid_admin_attributes) do
    {
      first_name: 'ValidAdminFirstName',
      last_name: 'ValidAdminLastName',
      email: 'valid_admin_email@example.com',
      username: 'validadminusername',
      password: 'P@ssw0rd',
      is_admin: true
    }
  end

  context 'User requests as Admin' do
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

    describe 'Get all users: GET /index' do
      before(:example) do
        get api_v1_users_url, headers: @headers
      end

      it 'renders a successful response' do
        expect(response.status).to eq(200)
      end

      it 'contains expected user attributes' do
        json_response_data = JSON.parse(response.body)['data']['data'][0]
        attributes = json_response_data['attributes']
        expect(attributes.keys).to match_array(%w[first_name last_name username email])
      end

      it 'contains all users' do
        expect(response.body).to include(@user.username.to_s)
      end
    end

    describe 'View a specific user: GET /show' do
      context 'the user exists' do
        before(:example) do
          get api_v1_user_url(@user.username), headers: @headers
        end

        it 'renders a successful response' do
          expect(response.status).to eq(200)
        end

        it 'contains expected user attributes' do
          json_response_data = JSON.parse(response.body)['data']['data']
          attributes = json_response_data['attributes']
          expect(attributes.keys).to match_array(%w[first_name last_name username email])
          expect(response.body).to include('projects')
          expect(response.body).to include('project_memberships')
          expect(response.body).to include('author_tickets')
          expect(response.body).to include('assignee_tickets')
          expect(response.body).to include('comments')
        end

        it 'contains specific user' do
          expect(response.body).to include(@user.username.to_s)
        end
      end

      context 'the user does not exist' do
        before(:example) do
          get '/api/v1/users/dne-username', headers: @headers
        end

        it 'throws an error' do
          expect(response.body).to include('errors')
          expect(response.status).to eq(422)
        end
      end
    end

    describe 'Admin user creates a new user: POST /create' do
      let(:invalid_attributes_1) do
        {
          first_name: 'ValidFirstName',
          last_name: 'ValidLastName',
          email: 'valid_email@example.com',
          username: 'Invalid Username',
          password: 'P@ssw0rd'
        }
      end

      let(:invalid_attributes_2) do
        {
          first_name: 'ValidFirstName',
          last_name: 'ValidLastName',
          email: 'valid_email@example.com',
          username: @user.username,
          password: 'P@ssw0rd'
        }
      end

      context 'valid attributes' do
        it 'creates a new user' do
          expect do
            post api_v1_users_url, params: valid_attributes, headers: @headers
          end.to change(User.all, :count).by(1)
          expect(response.status).to eq(200)
          @new_user = User.find_by(username: valid_attributes[:username])
          expect(@new_user.projects).to_not eq(Project.all)
        end

        it 'creates a new admin user and assigns all projects to user' do
          expect do
            post api_v1_users_url, params: valid_admin_attributes, headers: @headers
          end.to change(User.all, :count).by(1)
          expect(response.status).to eq(200)
          @new_admin = User.find_by(username: valid_admin_attributes[:username])
          expect(@new_admin.projects).to eq(Project.all)
        end
      end

      context 'invalid attributes' do
        it 'throws an error when username is invalid' do
          expect do
            post api_v1_users_url, params: invalid_attributes_1, headers: @headers
          end.to change(User.all, :count).by(0)
          expect(response.body).to include('errors')
          expect(response.status).to eq(422)
        end

        it 'throws an error when username is not unique' do
          expect do
            post api_v1_users_url, params: invalid_attributes_2, headers: @headers
          end.to change(User.all, :count).by(0)
          expect(response.body).to include('errors')
          expect(response.status).to eq(422)
        end
      end
    end

    describe 'Admin user updates a user: PATCH /update' do
      let(:new_attributes) do
        {
          first_name: 'ValidFirstNameUpdated',
          last_name: 'ValidLastNameUpdated'
        }
      end

      let(:invalid_attributes_1) do
        {
          first_name: nil,
          last_name: 'ValidLastName'
        }
      end

      let(:invalid_attributes_2) do
        {
          first_name: 'ValidFirstName',
          last_name: nil
        }
      end

      context 'valid attributes' do
        before(:example) do
          patch api_v1_user_url(@user.username), params: new_attributes, headers: @headers
        end

        it 'updates a user' do
          expect(User.find(@user.id).first_name).to eq(new_attributes[:first_name])
          expect(User.find(@user.id).last_name).to eq(new_attributes[:last_name])
          expect(response.status).to eq(200)
        end
      end

      context 'invalid attributes' do
        it 'throws an error when no first_name' do
          patch api_v1_user_url(@user.username), params: invalid_attributes_1, headers: @headers
          expect(@user.first_name).to_not eq(invalid_attributes_1[:first_name])
          expect(@user.last_name).to_not eq(invalid_attributes_1[:last_name])
          expect(response.body).to include('errors')
          expect(response.status).to eq(422)
        end

        it 'throws an error when no last_name' do
          patch api_v1_user_url(@user.username), params: invalid_attributes_2, headers: @headers
          expect(@user.first_name).to_not eq(invalid_attributes_2[:first_name])
          expect(@user.last_name).to_not eq(invalid_attributes_2[:last_name])
          expect(response.body).to include('errors')
          expect(response.status).to eq(422)
        end
      end
    end

    describe 'Admin user deletes a user: DELETE /destroy' do
      it 'deletes a user' do
        expect do
          delete api_v1_user_url(@user.username), headers: @headers
        end.to change(User.all, :count).by(-1)
        expect(response.status).to eq(200)
      end
    end
  end

  context 'User requests as Client' do
    before(:all) do
      @login_user = create(:user)
      @login_params = {
        email: @login_user.email,
        password: @login_user.password
      }
      post api_v1_user_session_url, params: @login_params
      @headers = {
        "Authorization": response.headers['Authorization']
      }
    end

    describe 'Get all users: GET /index' do
      before(:example) do
        get api_v1_users_url, headers: @headers
      end

      it 'renders a successful response' do
        expect(response.status).to eq(200)
      end

      it 'contains expected user attributes' do
        json_response_data = JSON.parse(response.body)['data']['data'][0]
        attributes = json_response_data['attributes']
        expect(attributes.keys).to match_array(%w[first_name last_name username email])
        expect(response.body).to include('projects')
        expect(response.body).to include('project_memberships')
        expect(response.body).to include('author_tickets')
        expect(response.body).to include('assignee_tickets')
        expect(response.body).to include('comments')
      end

      it 'contains all users' do
        expect(response.body).to include(@user.username.to_s)
      end
    end

    describe 'View a specific user: GET /show' do
      context 'the user exists' do
        before(:example) do
          get api_v1_user_url(@user.username), headers: @headers
        end

        it 'renders a successful response' do
          expect(response.status).to eq(200)
        end

        it 'contains expected user attributes' do
          json_response_data = JSON.parse(response.body)['data']['data']
          attributes = json_response_data['attributes']
          expect(attributes.keys).to match_array(%w[first_name last_name username email])
          expect(response.body).to include('projects')
          expect(response.body).to include('project_memberships')
          expect(response.body).to include('author_tickets')
          expect(response.body).to include('assignee_tickets')
          expect(response.body).to include('comments')
        end

        it 'contains specific user' do
          expect(response.body).to include(@user.username.to_s)
        end
      end

      context 'the user does not exist' do
        before(:example) do
          get '/api/v1/users/dne-username', headers: @headers
        end

        it 'throws an error' do
          expect(response.body).to include('errors')
          expect(response.status).to eq(422)
        end
      end
    end

    describe 'Client tries to create a new user: POST /create' do
      context 'valid attributes' do
        it 'is unauthorized' do
          expect do
            post api_v1_users_url, params: valid_attributes, headers: @headers
          end.to change(User.all, :count).by(0)
          expect(response.status).to eq(401)
        end
      end
    end

    describe 'Client tries to update a user: PATCH /update' do
      let(:new_attributes) do
        {
          first_name: 'ValidFirstNameUpdated',
          last_name: 'ValidLastNameUpdated'
        }
      end

      context 'valid attributes' do
        before(:example) do
          patch api_v1_user_url(@user.username), params: new_attributes, headers: @headers
        end

        it 'is unauthorized' do
          expect(@user.first_name).to_not eq(new_attributes[:first_name])
          expect(@user.last_name).to_not eq(new_attributes[:last_name])
          expect(response.status).to eq(401)
        end
      end
    end

    describe 'Client tries to delete a user: DELETE /destroy' do
      it 'is unauthorized' do
        expect do
          delete api_v1_user_url(@user.username), headers: @headers
        end.to change(User.all, :count).by(0)
        expect(response.status).to eq(401)
      end
    end
  end
end

require 'rails_helper'

RSpec.describe 'Tickets API Test', type: :request do
  before(:all) do
    @project = create(:project)
    @project.update(code: @project.name.parameterize)
    @user = create(:user)
    @login_params = {
      email: @user.email,
      password: @user.password
    }
    post api_v1_user_session_url, params: @login_params
    @headers = {
      "Authorization": response.headers['Authorization']
    }
    @project_membership = create(:project_membership, user: @user, project: @project)
  end

  let(:valid_attributes) do
    {
      title: 'ValidTicketTitle',
      description: 'ValidTicketDescription',
      status: 'Open'
    }
  end

  let(:invalid_attributes) do
    {
      title: nil,
      description: 'ValidTicketDescription',
      status: 'Closed'
    }
  end

  describe 'Get all tickets in a project: GET /index' do
    before(:example) do
      @ticket = create(:ticket, project: @project)
      get api_v1_project_tickets_url(@project.code), headers: @headers
    end

    it 'renders a successful response' do
      expect(response.status).to eq(200)
    end

    it 'contains expected ticket attributes' do
      json_response_data = JSON.parse(response.body)['data'][0]
      attributes = json_response_data['attributes']
      expect(attributes.keys).to match_array(%w[title description resolution status author_id
                                                assignee_id project_id ticket_no created_at updated_at])
    end

    it 'contains all tickets in a project' do
      expect(response.body).to include(@ticket.title.to_s)
    end
  end

  describe 'View a specific ticket: GET /show' do
    context 'the ticket exists' do
      before(:example) do
        @ticket = create(:ticket, project: @project, author: @user)
        get api_v1_project_ticket_url(@project.code, @ticket.ticket_no), headers: @headers
      end

      it 'renders a successful response' do
        expect(response.status).to eq(200)
      end

      it 'contains expected ticket attributes' do
        json_response_data = JSON.parse(response.body)['data']
        attributes = json_response_data['attributes']
        expect(attributes.keys).to match_array(%w[title description resolution status author_id
                                                  assignee_id project_id ticket_no created_at updated_at])
      end

      it 'contains specific ticket' do
        expect(response.body).to include(@ticket.title.to_s)
      end
    end

    context 'the ticket does not exist' do
      before(:example) do
        get "/api/v1/projects/#{@project.code}/tickets/dne", headers: @headers
      end

      it 'throws an error' do
        expect(response.body).to include('errors')
        expect(response.status).to eq(200)
      end
    end
  end

  describe 'User creates a new ticket on a project: POST /create' do
    context 'valid attributes' do
      before(:example) do
        @user2 = create(:user)
        @project2 = create(:project)
        @project2.update(code: @project2.name.parameterize)
      end

      it 'creates a new ticket with current user account only' do
        expect do
          post api_v1_project_tickets_url(@project.code), params: valid_attributes, headers: @headers
        end.to change(@user.author_tickets, :count).by(1)
        expect do
          post api_v1_project_tickets_url(@project.code), params: valid_attributes, headers: @headers
        end.to change(@user2.author_tickets, :count).by(0)
        expect(response.status).to eq(200)
      end

      it 'creates a new ticket on current project only' do
        expect do
          post api_v1_project_tickets_url(@project.code), params: valid_attributes, headers: @headers
        end.to change(@project.tickets, :count).by(1)
        expect do
          post api_v1_project_tickets_url(@project.code), params: valid_attributes, headers: @headers
        end.to change(@project2.tickets, :count).by(0)
        expect(response.status).to eq(200)
      end

      it 'updates project last ticket no.' do
        post api_v1_project_tickets_url(@project.code), params: valid_attributes, headers: @headers
        expect(Project.find(@project.id).last_ticket_no).to eq(1)
        expect(response.status).to eq(200)
      end
    end

    context 'invalid attributes' do
      it 'throws an error when no title' do
        expect do
          post api_v1_project_tickets_url(@project.code), params: invalid_attributes, headers: @headers
        end.to change(Ticket.all, :count).by(0)
        expect(response.body).to include('errors')
        expect(response.status).to eq(422)
      end
    end
  end

  describe 'User updates a ticket: PATCH /update' do
    before(:example) do
      @ticket = create(:ticket, project: @project, author: @user)
    end

    let(:new_attributes) do
      {
        title: 'ValidTicketTitleUpdated',
        description: 'ValidTicketDescriptionUpdated',
        resolution: 'ValidTicketResolution',
        status: 'Closed',
        assignee_id: @user.id
      }
    end

    context 'valid attributes' do
      it 'updates a ticket' do
        patch api_v1_project_ticket_url(@project.code, @ticket.ticket_no), params: new_attributes,
                                                                           headers: @headers
        expect(Ticket.find(@ticket.id).description).to eq(new_attributes[:description])
        expect(Ticket.find(@ticket.id).title).to eq(new_attributes[:title])
        expect(Ticket.find(@ticket.id).resolution).to eq(new_attributes[:resolution])
        expect(Ticket.find(@ticket.id).status).to eq(new_attributes[:status])
        expect(Ticket.find(@ticket.id).assignee_id).to eq(new_attributes[:assignee_id])
        expect(response.status).to eq(200)
      end
    end

    context 'invalid attributes' do
      it 'throws an error when no title' do
        patch api_v1_project_ticket_url(@project.code, @ticket.ticket_no), params: invalid_attributes,
                                                                           headers: @headers
        expect(Ticket.find(@ticket.id).title).to_not eq(invalid_attributes[:title])
        expect(Ticket.find(@ticket.id).description).to_not eq(invalid_attributes[:description])
        expect(Ticket.find(@ticket.id).status).to_not eq(invalid_attributes[:status])
        expect(response.body).to include('errors')
        expect(response.status).to eq(422)
      end
    end
  end

  describe 'User deletes a ticket: DELETE /destroy' do
    before(:example) do
      @ticket = create(:ticket, project: @project, author: @user)
    end

    it 'deletes a ticket' do
      expect do
        delete api_v1_project_ticket_url(@project.code, @ticket.ticket_no), headers: @headers
      end.to change(@user.author_tickets, :count).by(-1)
      expect(response.status).to eq(200)
    end
  end
end

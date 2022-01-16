require 'rails_helper'

RSpec.describe 'TicketRelations', type: :request do
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
    @ticket = create(:ticket, author: @user, project: @project)
    @ticket2 = create(:ticket, author: @user, project: @project)
  end

  let(:valid_attributes) do
    {
      ticket_id: @ticket.id,
      related_ticket_id: @ticket2.id
    }
  end

  describe 'Add related ticket' do
    before(:example) do
      post api_v1_add_related_ticket_url(@project.code, @ticket.ticket_no), params: valid_attributes, headers: @headers
    end

    it 'renders a successful response' do
      expect(response.status).to eq(200)
    end

    it 'relates specified ticket to current ticket' do
      expect(Ticket.find(@ticket.id).related_tickets.count).to eq(1)
      expect(Ticket.find(@ticket.id).related_tickets.to_json).to include(@ticket2.id)
      expect(Ticket.find(@ticket2.id).inverse_related_tickets.count).to eq(1)
      expect(Ticket.find(@ticket2.id).inverse_related_tickets.to_json).to include(@ticket.id)
    end
  end

  describe 'Delete related ticket' do
    before(:example) do
      post api_v1_add_related_ticket_url(@project.code, @ticket.ticket_no), params: valid_attributes, headers: @headers
      delete api_v1_delete_related_ticket_url(@project.code, @ticket.ticket_no), params: valid_attributes,
                                                                                 headers: @headers
    end

    it 'renders a successful response' do
      expect(response.status).to eq(200)
    end

    it 'removes relation of specified ticket to current ticket' do
      expect(Ticket.find(@ticket.id).related_tickets.count).to eq(0)
      expect(Ticket.find(@ticket.id).related_tickets.to_json).to_not include(@ticket2.id)
      expect(Ticket.find(@ticket2.id).inverse_related_tickets.count).to eq(0)
      expect(Ticket.find(@ticket2.id).inverse_related_tickets.to_json).to_not include(@ticket.id)
    end
  end
end

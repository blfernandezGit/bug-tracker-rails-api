require 'rails_helper'

RSpec.describe "TicketRelations", type: :request do
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
        "Authorization": response.headers["Authorization"]
    }
    @project_membership = create(:project_membership, user: @user, project: @project)
    @ticket = create(:ticket, author: @user, project: @project)
    @ticket2 = create(:ticket, author: @user, project: @project)
  end

  describe "Add related ticket" do
    let(:valid_attributes) {
      {
        ticket_id: @ticket.id,
        related_ticket_id: @ticket2.id
      }
    }
    
    before(:example) { post api_v1_add_related_ticket_url, params: valid_attributes, headers: @headers}

    it "renders a successful response" do
      expect(response.status).to eq(200)
    end

    it "relates specified ticket to current ticket" do
      expect(@ticket.related_tickets.count).to eq(1)
      expect(@ticket.related_tickets.to_json).to include(@ticket2.id)
      expect(@ticket2.related_tickets.count).to eq(1)
      expect(@ticket2.related_tickets.to_json).to include(@ticket.id)
    end
  end
end
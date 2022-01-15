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
            "Authorization": response.headers["Authorization"]
        }
        @project_membership = create(:project_membership, user: @user, project: @project)
    end

    let(:valid_attributes) {
        {
            title: "ValidTicketTitle",
            description: "ValidTicketDescription",
            status: "Open"
        }
    }

    let(:new_attributes) {
        {
            title: "ValidTicketTitleUpdated",
            description: "ValidTicketDescriptionUpdated",
            resolution: "ValidTicketResolution",
            status: "Closed"
        }
    }

    describe 'View a specific ticket: GET /show' do
        before(:example) { 
            @ticket = create(:ticket, project: @project, author: @user)
            get api_v1_project_ticket_url(@project.code, @ticket.ticket_no), headers: @headers
        }

        it "renders a successful response" do
            expect(response.status).to eq(200)
        end

        it "contains expected ticket attributes" do
            json_response_data = JSON.parse(response.body)['data']['data'][0]
            attributes = json_response_data['attributes']
            expect(attributes.keys).to match_array(["title", "description", "resolution", "status", "author_id", "assignee_id", "project_id"])
        end

        it "contains specific ticket" do
            expect(response.body).to include(@ticket.title.to_s)
        end
    end

    describe 'User creates a new ticket on a project: POST /create' do
        before(:example) { 
            @user2 = create(:user) 
            @project2 = create(:project)
            @project2.update(code: @project2.name.parameterize)
        }

        it "creates a new ticket with current user account only" do
            expect { 
                post api_v1_project_tickets_url(@project.code), params: { ticket: valid_attributes }, headers: @headers
            }.to change(@user.author_tickets, :count).by(1)
            expect { 
                post api_v1_project_tickets_url(@project.code), params: { ticket: valid_attributes }, headers: @headers
            }.to change(@user2.author_tickets, :count).by(0)
            expect(response.status).to eq(200)
        end

        it "creates a new ticket on current project only" do
            expect { 
                post api_v1_project_tickets_url(@project.code), params: { ticket: valid_attributes }, headers: @headers
            }.to change(@project.tickets, :count).by(1)
            expect { 
                post api_v1_project_tickets_url(@project.code), params: { ticket: valid_attributes }, headers: @headers
            }.to change(@project2.tickets, :count).by(0)
            expect(response.status).to eq(200)
        end
    end

    describe 'User updates a ticket: PATCH /update' do
        before(:example) { 
            @ticket = create(:ticket, project: @project, author: @user)
            patch api_v1_project_ticket_url(@project.code,@ticket.ticket_no), params: { ticket: new_attributes }, headers: @headers
        }

        it "updates a ticket" do
            expect(Ticket.find(@ticket.id).description).to eq(new_attributes[:description])
            expect(Ticket.find(@ticket.id).title).to eq(new_attributes[:title])
            expect(Ticket.find(@ticket.id).resolution).to eq(new_attributes[:resolution])
            expect(Ticket.find(@ticket.id).status).to eq(new_attributes[:status])
            expect(response.status).to eq(200)
        end
    end

    describe 'User deletes a ticket: DELETE /destroy' do
        before(:example) { 
            @ticket = create(:ticket, project: @project, author: @user)
        }

        it "deletes a ticket" do
            expect { 
                delete api_v1_project_ticket_url(@project.code,@ticket.ticket_no), headers: @headers
            }.to change(@user.author_tickets, :count).by(-1)
            expect(response.status).to eq(200)
        end
    end
end
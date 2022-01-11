require 'rails_helper'

@user = nil
@project = nil
@user2 = nil
@project2 = nil
@ticket = nil

RSpec.describe Api::V1::TicketsRequests, type: :request do
    before(:all) do
        @project = create(:project)
        @user = create(:user)
        @project_membership = create(:project_membership, user: @user, project: @project)
        sign_in @user
    end

    let(:valid_attributes) {
        {
            title: "ValidTicketTitle"
            description: "ValidTicketDescription"
            status: "Open"
        }
    }

    let(:new_attributes) {
        {
            title: "ValidTicketTitleUpdated"
            description: "ValidTicketDescriptionUpdated"
            resolution: "ValidTicketResolution"
            status: "Closed"
        }
    }

    describe 'Get all tickets in a project: GET /index' do
        before(:example) { 
            @user2 = create(:user)
            @ticket = create(:ticket, project: @project, user: @user)
            get project_tickets_url(@project) 
        }

        it "renders a successful response" do
            expect(response.status).to eq(200)
        end

        it "contains expected comment attributes" do
            json_response = JSON.parse(response.body)
            expect(hash_body.keys).to match_array([:id, :title, :description, :resolution, :status, :user_id, :project_id])
        end

        it "contains all tickets in the current project" do
            expect(response.body).to include(@ticket)
        end
    end

    describe 'Get all tickets made by user: GET /index' do
        before(:example) { 
            @project2 = create(:project)
            @ticket = create(:ticket, project: @project2, user: @user)
            get user_tickets_url(@user)
        }
        
        it "renders a successful response" do
            expect(response.status).to eq(200)
        end

        it "contains expected comment attributes" do
            json_response = JSON.parse(response.body)
            expect(hash_body.keys).to match_array([:id, :title, :description, :resolution, :status, :user_id, :project_id])
        end

        it "contains all comments made by the current user" do
            expect(response.body).to include(@ticket)
        end
    end

    describe 'User adds a new ticket: GET /new' do
        before(:example) { get new_project_ticket_url(@project) }

        it "renders a successful response" do
            expect(response.status).to eq(200)
        end
    end

    describe 'User creates a new ticket: POST /create' do
        before(:example) { 
            @user2 = create(:user) 
            @project2 = create(:project)
        }

        it "creates a new ticket with current user account only" do
            expect { 
                post project_tickets_url(@project), params: { ticket: valid_attributes }
            }.to change(@user.tickets, :count).by(1)
            expect { 
                post project_tickets_url(@project), params: { ticket: valid_attributes }
            }.to change(@user2.tickets, :count).by(0)
            expect(response.status).to eq(200)
        end

        it "creates a new ticket on current project only" do
            expect { 
                post project_tickets_url(@project), params: { ticket: valid_attributes }
            }.to change(@project.tickets, :count).by(1)
            expect { 
                post project_tickets_url(@project), params: { ticket: valid_attributes }
            }.to change(@project2.tickets, :count).by(0)
            expect(response.status).to eq(200)
        end
    end

    describe 'User edits a ticket: GET /edit' do
        before(:example) { 
            @ticket = create(:ticket, project: @project, user: @user)
            get edit_project_ticket_url(@ticket, @project) 
        }

        it "renders a successful response" do
            expect(response.status).to eq(200)
        end
    end

    describe 'User updates a ticket: PATCH /update' do
        before(:example) { 
            @ticket = create(:ticket, project: @project, user: @user)
        }

        it "updates a ticket" do
            expect { 
                patch project_ticket_url(@ticket, @project), params: { ticket: new_attributes }
            }.to change(@ticket, :description).to('ValidTicketDescriptionUpdated')
            expect(@ticket.title).to eq("ValidTicketTitleUpdated")
            expect(@ticket.resolution).to eq("ValidTicketResolution")
            expect(@ticket.status).to eq("Closed")
            expect(response.status).to eq(200)
        end
    end

    describe 'User deletes a ticket: DELETE /destroy' do
        before(:example) { 
            @ticket = create(:ticket, project: @project, user: @user)
        }

        it "deletes a ticket" do
            expect { 
                delete project_ticket_url(@ticket, @project)
            }.to change(@user.tickets, :count).by(-1)
            expect(response.status).to eq(200)
        end
    end
end
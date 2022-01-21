require 'rails_helper'

# TODO: change error code when does not exist to 404 - project, ticket, user? (spec and controller)

RSpec.describe 'Comments API Test', type: :request do
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
  end

  let(:valid_attributes) do
    {
      comment_text: 'ValidCommentText'
    }
  end

  let(:invalid_attributes) do
    {
      comment_text: nil
    }
  end

  describe 'Get all comments in a ticket: GET /index' do
    before(:example) do
      @comment = create(:comment, ticket: @ticket)
      get api_v1_project_ticket_comments_url(@project.code, @ticket.ticket_no), headers: @headers
    end

    it 'renders a successful response' do
      expect(response.status).to eq(200)
    end

    it 'contains expected comment attributes' do
      json_response_data = JSON.parse(response.body)['data'][0]
      attributes = json_response_data['attributes']
      expect(attributes.keys).to match_array(%w[comment_text ticket_id user_id created_at updated_at])
    end

    it 'contains all comments in a ticket' do
      expect(response.body).to include(@comment.comment_text.to_s)
    end
  end

  describe 'Retrieve a specific comment: GET /show' do
    context 'the comment exists' do
      before(:example) do
        @comment = create(:comment, ticket: @ticket, user: @user)
        get api_v1_project_ticket_comment_url(@project.code, @ticket.ticket_no, @comment.id), headers: @headers
      end

      it 'renders a successful response' do
        expect(response.status).to eq(200)
      end

      it 'contains expected comment attributes' do
        json_response_data = JSON.parse(response.body)['data']
        attributes = json_response_data['attributes']
        expect(attributes.keys).to match_array(%w[comment_text ticket_id user_id created_at updated_at])
      end

      it 'contains specific comment' do
        expect(response.body).to include(@comment.comment_text.to_s)
      end
    end

    context 'the comment does not exist' do
      before(:example) do
        get "/api/v1/projects/#{@project.code}/tickets/#{@ticket.ticket_no}/comments/dne", headers: @headers
      end

      it 'throws an error' do
        expect(response.body).to include('errors')
        expect(response.status).to eq(404)
      end
    end
  end

  describe 'User creates a new comment: POST /create' do
    context 'valid attributes' do
      before(:example) do
        @user2 = create(:user)
        @ticket2 = create(:ticket)
      end

      it 'creates a new comment with current user account only' do
        expect do
          post api_v1_project_ticket_comments_url(@project.code, @ticket.ticket_no), params: valid_attributes,
                                                                                     headers: @headers
        end.to change(@user.comments, :count).by(1)
        expect do
          post api_v1_project_ticket_comments_url(@project.code, @ticket.ticket_no), params: valid_attributes,
                                                                                     headers: @headers
        end.to change(@user2.comments, :count).by(0)
        expect(response.status).to eq(200)
      end

      it 'creates a new comment on current ticket only' do
        expect do
          post api_v1_project_ticket_comments_url(@project.code, @ticket.ticket_no), params: valid_attributes,
                                                                                     headers: @headers
        end.to change(@ticket.comments, :count).by(1)
        expect do
          post api_v1_project_ticket_comments_url(@project.code, @ticket.ticket_no), params: valid_attributes,
                                                                                     headers: @headers
        end.to change(@ticket2.comments, :count).by(0)
        expect(response.status).to eq(200)
      end
    end

    context 'invalid attributes' do
      it 'throws an error when no comment text' do
        expect do
          post api_v1_project_ticket_comments_url(@project.code, @ticket.ticket_no), params: invalid_attributes,
                                                                                     headers: @headers
        end.to change(Ticket.all, :count).by(0)
        expect(response.body).to include('errors')
        expect(response.status).to eq(422)
      end
    end
  end

  describe 'User updates a comment: PATCH /update' do
    before(:example) do
      @comment = create(:comment, ticket: @ticket, user: @user)
    end

    let(:new_attributes) do
      {
        comment_text: 'ValidCommentTextUpdated'
      }
    end

    context 'valid attributes' do
      it 'updates a comment' do
        patch api_v1_project_ticket_comment_url(@project.code, @ticket.ticket_no, @comment.id), params: new_attributes,
                                                                                                headers: @headers
        expect(Comment.find(@comment.id).comment_text).to eq(new_attributes[:comment_text])
        expect(response.status).to eq(200)
      end
    end

    context 'invalid attributes' do
      it 'throws an error when no title' do
        patch api_v1_project_ticket_comment_url(@project.code, @ticket.ticket_no, @comment.id),
              params: invalid_attributes, headers: @headers
        expect(Comment.find(@comment.id).comment_text).to_not eq(invalid_attributes[:comment_text])
        expect(response.body).to include('errors')
        expect(response.status).to eq(422)
      end
    end
  end

  describe 'User deletes a comment: DELETE /destroy' do
    before(:example) do
      @comment = create(:comment, ticket: @ticket, user: @user)
    end

    it 'deletes a comment' do
      expect do
        delete api_v1_project_ticket_comment_url(@project.code, @ticket.ticket_no, @comment.id), headers: @headers
      end.to change(@user.comments, :count).by(-1)
      expect(response.status).to eq(200)
    end
  end
end

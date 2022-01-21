class Api::V1::CommentsController < Api::V1::RootController
  before_action :get_user, :get_ticket
  before_action :set_comment, only: %i[show update destroy]

  def index
    @comments = @ticket.comments
    if @comments.count > 0
      render json: CommentSerializer.new(@comments).serializable_hash.merge!({
                                                                               status: '200',
                                                                               messages: ['Comments successfully retrieved.']
                                                                             }), status: :ok
    else
      render json: {
        status: '422',
        errors: [
          title: 'Unprocessable Entity',
          messages: ['No projects found.']
        ]
      }, status: :ok
    end
  end

  def show
    if @comment
      render json: CommentSerializer.new(@comment).serializable_hash.merge!({
                                                                              status: '200',
                                                                              messages: ['Comment successfully retrieved.']
                                                                            }), status: :ok
    else
      render json: {
        status: '422',
        errors: [
          title: 'Unprocessable Entity',
          messages: ['Comment does not exist.']
        ]
      }, status: :ok
    end
  end

  def create
    @comment = @ticket.comments.build(comment_params)
    @comment.user_id = @user.id # Assign current user as comment author

    if @comment.save
      render json: CommentSerializer.new(@comment).serializable_hash.merge!({
                                                                              status: '200',
                                                                              messages: ['Ticket successfully created.']
                                                                            }), status: :ok
    else
      render json: {
        status: '422',
        errors: [
          title: 'Unprocessable Entity',
          messages: @comment.errors.full_messages
        ]
      }, status: :unprocessable_entity
    end
  end

  def update
    if @comment.update(comment_params)
      render json: CommentSerializer.new(@comment).serializable_hash.merge!({
                                                                              status: '200',
                                                                              messages: ['Ticket successfully updated.']
                                                                            }), status: :ok
    else
      render json: {
        status: '422',
        errors: [
          title: 'Unprocessable Entity',
          messages: @comment.errors.full_messages
        ]
      }, status: :unprocessable_entity
    end
  end

  def destroy
    if @comment.destroy
      render json: { data: { user: @comment.user } }.merge!({
                                                              status: '200',
                                                              messages: ['Ticket successfully deleted.']
                                                            }), status: :ok
    else
      render json: {
        status: '422',
        errors: [
          title: 'Unprocessable Entity',
          messages: @comment.errors.full_messages
        ]
      }, status: :unprocessable_entity
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def get_ticket
    @ticket = Ticket.find_by(ticket_no: params[:ticket_ticket_no],
                             project_id: Project.find_by(code: params[:project_code]))
  end

  def get_user
    @user = User.find(current_api_v1_user.id)
  end

  def set_comment
    @comment = Comment.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def comment_params
    params.permit(:id, :comment_text)
  end
end

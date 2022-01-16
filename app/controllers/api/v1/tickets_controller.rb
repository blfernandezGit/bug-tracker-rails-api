class Api::V1::TicketsController < Api::V1::RootController
  before_action :get_user, :get_project
  before_action :set_ticket, only: %i[show update destroy]

  def show
    if @ticket
      render json: {
        status: '200',
        data: TicketSerializer.new(@ticket).serializable_hash,
        messages: ['Ticket successfully retrieved.']
      }, status: :ok
    else
      render json: {
        status: '422',
        errors: [
          title: 'Unprocessable Entity',
          messages: ['Ticket does not exist.']
        ]
      }, status: :unprocessable_entity
    end
  end

  def create
    @ticket = @project.tickets.build(ticket_params)
    @ticket.author_id = @user.id # Assign current user as ticket author

    # Assign ticket no.
    @ticket.ticket_no = if !@project.last_ticket_no
                          1
                        else
                          @project.last_ticket_no + 1
                        end

    # Assign last ticket no. for the project
    @project.update(last_ticket_no: @ticket.ticket_no)

    if @ticket.save
      render json: {
        status: '200',
        data: TicketSerializer.new(@ticket).serializable_hash,
        messages: ['Ticket successfully created.']
      }, status: :ok
    else
      render json: {
        status: '422',
        errors: [
          title: 'Unprocessable Entity',
          messages: @ticket.errors.full_messages
        ]
      }, status: :unprocessable_entity
    end
  end

  def update
    if @ticket.update(ticket_params)
      render json: {
        status: '200',
        data: TicketSerializer.new(@ticket).serializable_hash,
        messages: ['Ticket successfully updated.']
      }, status: :ok
    else
      render json: {
        status: '422',
        errors: [
          title: 'Unprocessable Entity',
          messages: @ticket.errors.full_messages
        ]
      }, status: :unprocessable_entity
    end
  end

  def destroy
    if @ticket.destroy
      render json: {
        status: '200',
        deletedData: TicketSerializer.new(@ticket).serializable_hash,
        messages: ['Ticket successfully deleted.']
      }, status: :ok
    else
      render json: {
        status: '422',
        errors: [
          title: 'Unprocessable Entity',
          messages: @ticket.errors.full_messages
        ]
      }, status: :unprocessable_entity
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def get_project
    @project = Project.find_by(code: params[:project_code])
  end

  def get_user
    @user = User.find(current_api_v1_user.id)
  end

  def set_ticket
    @ticket = Ticket.where(ticket_no: params[:ticket_no], project_id: @project.id)[0]
  end

  # Only allow a list of trusted parameters through.
  def ticket_params
    params.permit(:ticket_no, :title, :description, :resolution, :status, :assignee_id)
  end
end

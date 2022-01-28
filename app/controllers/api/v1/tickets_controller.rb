class Api::V1::TicketsController < Api::V1::RootController
  before_action :get_user, :get_project
  before_action :set_ticket, only: %i[show update destroy]

  def get_all
    @tickets = Ticket.all.order(updated_at: :desc)
    if @tickets.count > 0
      render json: TicketsSerializer.new(@tickets).serializable_hash.merge!({
                                                                             status: '200',
                                                                             messages: ['Tickets successfully retrieved.']
                                                                           }), status: :ok
    else
      render json: {
        status: '422',
        errors: [
          title: 'Unprocessable Entity',
          messages: ['No Tickets found.']
        ]
      }, status: :ok
    end
  end

  def index
    @tickets = @project.tickets.order(updated_at: :desc)
    if @tickets.count > 0
      render json: TicketsSerializer.new(@tickets).serializable_hash.merge!({
                                                                             status: '200',
                                                                             messages: ['Tickets successfully retrieved.']
                                                                           }), status: :ok
    else
      render json: {
        status: '422',
        errors: [
          title: 'Unprocessable Entity',
          messages: ['No Tickets found.']
        ]
      }, status: :ok
    end
  end

  def show
    if @ticket
      render json: TicketSerializer.new(@ticket).serializable_hash.merge!({
                                                                            status: '200',
                                                                            messages: ['Ticket successfully retrieved.']
                                                                          }), status: :ok
    else
      render json: {
        status: '422',
        errors: [
          title: 'Unprocessable Entity',
          messages: ['Ticket does not exist.']
        ]
      }, status: :ok
    end
  end

  def create
    @ticket = @project.tickets.build(ticket_params)
    @ticket.image.attach(image_params[:image]) if image_params[:image]
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
      render json: TicketSerializer.new(@ticket).serializable_hash.merge!({
                                                                            status: '200',
                                                                            messages: ['Ticket successfully created.']
                                                                          }), status: :ok
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
      @ticket.image.attach(image_params[:image]) if image_params[:image]
      if image_params[:image]
        @ticket.image.attach(image_params[:image]) 
      elsif image_params[:delete_image]
        @ticket.image.destroy
      end
      render json: TicketSerializer.new(@ticket).serializable_hash.merge!({
                                                                            status: '200',
                                                                            messages: ['Ticket successfully updated.']
                                                                          }), status: :ok
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
      render json: TicketSerializer.new(@ticket).serializable_hash.merge!({
                                                                            status: '200',
                                                                            messages: ['Ticket successfully deleted.']
                                                                          }), status: :ok
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
    @ticket = Ticket.find_by(ticket_no: params[:ticket_no], project_id: @project.id)
  end

  # Only allow a list of trusted parameters through.
  def ticket_params
    params.permit(:ticket_no, :title, :description, :resolution, :status, :assignee_id)
  end

  def image_params
    params.permit(:image, :delete_image)
  end
end

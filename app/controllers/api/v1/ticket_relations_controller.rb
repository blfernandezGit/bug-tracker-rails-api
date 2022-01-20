class Api::V1::TicketRelationsController < Api::V1::RootController
  before_action :set_tickets

  def add_related_ticket
    if !@ticket.related_tickets.include?(@related_ticket) && !@ticket.inverse_related_tickets.include?(@related_ticket)
      @ticket_relation = @ticket.ticket_relations.build(related_ticket_id: @related_ticket.id)
      if @ticket_relation.save
        render json: { data: {
          ticket_id: @ticket.id,
          related_ticket_id: @related_ticket.id
        } }.merge!({
                     status: '200',
                     messages: ['Tickets successfully related.']
                   }), status: :ok
      else
        render json: {
          status: '422',
          errors: [
            title: 'Unprocessable Entity',
            messages: ['Unable to relate tickets.']
          ]
        }, status: :unprocessable_entity
      end
    else
      render json: {
        status: '422',
        errors: [
          title: 'Unprocessable Entity',
          messages: ['Tickets are already related.']
        ]
      }, status: :unprocessable_entity
    end
  end

  def delete_related_ticket
    @ticket_relation = TicketRelation.find_by(ticket_id: @ticket.id, related_ticket_id: @related_ticket.id)

    @ticket_relation ||= TicketRelation.find_by(ticket_id: @related_ticket.id, related_ticket_id: @ticket.id)

    if @ticket_relation.destroy
      render json: { data: {
        ticket_id: @ticket.id,
        related_ticket_id: @related_ticket.id
      } }.merge!({
                   status: '200',
                   messages: ['Successfully remove tickets relation.']
                 }), status: :ok
    else
      render json: {
        status: '422',
        errors: [
          title: 'Unprocessable Entity',
          messages: @ticket_relation.errors.full_messages
        ]
      }, status: :unprocessable_entity
    end
  end

  private

  def set_tickets
    @ticket = Ticket.find_by(project_id: Project.find_by(code: params[:project_code]),
                             ticket_no: params[:ticket_ticket_no])
    @related_ticket = Ticket.find(ticket_relation_params[:related_ticket_id])
  end

  # Only allow a list of trusted parameters through.
  def ticket_relation_params
    params.permit(:related_ticket_id)
  end
end

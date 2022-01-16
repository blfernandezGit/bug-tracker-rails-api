require 'rails_helper'

RSpec.describe TicketRelation, type: :model do
  context 'Associations' do
    it {
      is_expected.to belong_to(:related_ticket)
        .class_name('Ticket')
    }
    it { is_expected.to belong_to(:ticket) }
  end
end

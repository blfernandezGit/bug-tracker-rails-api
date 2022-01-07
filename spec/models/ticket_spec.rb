require 'rails_helper'

RSpec.describe Ticket, type: :model do
  context 'Associations' do
    it { is_expected.to have_many(:ticket_relations)}
    it { is_expected.to have_many(:related_tickets).
          through(:ticket_relations).
          source(:ticket)}
    it { is_expected.to have_many(:inverse_ticket_relations).
          class_name('TicketRelation')}
    it { is_expected.to have_many(:inverse_related_tickets).
          through(:inverse_ticket_relations).
          source(:ticket)}
    it { is_expected.to have_many(:comments)}
    it { is_expected.to belong_to(:author).
          class_name('User')}
    it { is_expected.to belong_to(:assignee).
      class_name('User')}
    it { is_expected.to belong_to(:project)}
  end

  context 'Validations' do
    it { is_expected.to validate_presence_of(:title)}
    it { is_expected.not_to validate_presence_of(:description)}
    it { is_expected.to validate_inclusion_of(:status).in_array(%w['Open' 'For Fixing' 'For Testing' 'Closed' 'Cancelled']) }
  end
end
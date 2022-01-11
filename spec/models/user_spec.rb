require 'rails_helper'

RSpec.describe User, type: :model do
  context 'Associations' do
    it { is_expected.to have_many(:project_memberships)}
    it { is_expected.to have_many(:projects).
          through(:project_memberships)}
    it { is_expected.to have_many(:author_tickets).
          class_name('Ticket')}
    it { is_expected.to have_many(:assignee_tickets).
          class_name('Ticket')}
    it { is_expected.to have_many(:comments)}
  end

  context 'ActiveRecords' do
    it { is_expected.to have_db_index(:username)}
  end

  context 'Validations' do
    before(:example) {create(:user)}
    it { is_expected.to validate_presence_of(:first_name)}
    it { is_expected.to validate_presence_of(:last_name)}
    it { is_expected.to validate_presence_of(:username)}
    it { is_expected.to validate_uniqueness_of(:username) }
  end
end
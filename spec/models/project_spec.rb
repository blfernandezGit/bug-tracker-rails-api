require 'rails_helper'

RSpec.describe Project, type: :model do
  context 'Associations' do
    it { is_expected.to have_many(:project_memberships)}
    it { is_expected.to have_many(:users).
          through(:project_memberships)}
  end

  context 'ActiveRecords' do
    it { is_expected.to have_db_index(:code)}
  end

  context 'Validations' do
    subject { create(:project) }
    it { is_expected.to validate_presence_of(:name)}
    it { is_expected.to validate_presence_of(:code)}
    it { is_expected.to validate_uniqueness_of(:code)}
  end
end
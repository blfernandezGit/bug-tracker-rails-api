require 'rails_helper'

RSpec.describe User, type: :model do
  # Association Tests
  it { should have_many(:project_memberships)}
  it { should have_many(:projects)}
  it { should have_many(:author_tickets)}
  it { should have_many(:assignee_tickets)}
  it { should have_many(:comments)}

  # Validation Tests
  it { is_expected.to validate_presence_of(:first_name)}
end
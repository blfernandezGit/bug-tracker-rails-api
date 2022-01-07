require 'rails_helper'

RSpec.describe Comment, type: :model do
  context 'Associations' do
    it { is_expected.to belong_to(:user)}
    it { is_expected.to belong_to(:ticket)}
  end

  context 'Validations' do
    it { is_expected.to validate_presence_of(:comment_text)}
  end
end
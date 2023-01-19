require 'rails_helper'

RSpec.describe User, type: :model do
  it "is valid with a email, password" do
    expect(FactoryBot.build(:user)).to be_valid
  end
  
  it "is invalid without email" do
    user = User.new(email: nil)
    user.valid?
    expect(user.errors[:email]).to include("を入力してください")
  end

  it "is invalid without password" do
    user = User.new(password: nil)
    user.valid?
    expect(user.errors[:password]).to include("を入力してください")
  end
end

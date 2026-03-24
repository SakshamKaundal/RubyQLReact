# spec/models/user_spec.rb
# This file tests the User model

require 'rails_helper'

RSpec.describe User, type: :model do
  # Test 1: Can we create a user?
  it "can create a user with a name" do
    # Arrange: Create a user (like you would in the console)
    user = User.create(name: "Alice")

    # Act & Assert: Check if the name matches
    expect(user.name).to eq("Alice")
  end
end

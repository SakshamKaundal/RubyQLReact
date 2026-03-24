# spec/models/user_spec.rb
require 'rails_helper'

RSpec.describe User, type: :model do
  describe "associations" do
    it "has many posts" do
      user = User.create!(name: "Test User")
      expect(user.posts).to be_a(ActiveRecord::Associations::CollectionProxy)
    end

    it "has many comments" do
      user = User.create!(name: "Test User")
      expect(user.comments).to be_a(ActiveRecord::Associations::CollectionProxy)
    end

    it "posts are associated through user_id" do
      user = User.create!(name: "Alice")
      post = user.posts.create!(title: "My Post", body: "Content")

      expect(post.user).to eq(user)
      expect(post.user_id).to eq(user.id)
    end

    it "comments are associated through user_id" do
      user = User.create!(name: "Bob")
      post = user.posts.create!(title: "Test", body: "Body")
      comment = post.comments.create!(body: "Nice!", user: user)

      expect(comment.user).to eq(user)
      expect(comment.user_id).to eq(user.id)
    end

    it "destroys associated posts when user is destroyed" do
      user = User.create!(name: "Alice")
      post = user.posts.create!(title: "My Post", body: "Content")

      expect { user.destroy }.to change { Post.count }.by(-1)
    end

    it "destroys associated comments when user is destroyed" do
      user = User.create!(name: "Bob")
      post = user.posts.create!(title: "Test", body: "Body")
      comment = post.comments.create!(body: "Nice!", user: user)

      expect { user.destroy }.to change { Comment.count }.by(-1)
    end
  end

  describe "attributes" do
    it "has a name attribute" do
      user = User.create!(name: "Charlie")
      expect(user.name).to eq("Charlie")
    end

    it "name can be nil" do
      user = User.create!(name: nil)
      expect(user.name).to be_nil
    end

    it "can have duplicate names (no validation)" do
      User.create!(name: "Alice")
      user = User.new(name: "Alice")
      expect(user).to be_valid  # No uniqueness validation
    end
  end

  describe "callbacks" do
    it "creates timestamps automatically" do
      user = User.create!(name: "Dave")
      expect(user.created_at).to be_a(ActiveSupport::TimeWithZone)
      expect(user.updated_at).to be_a(ActiveSupport::TimeWithZone)
    end

    it "updates updated_at on save" do
      user = User.create!(name: "Eve")
      original_updated = user.updated_at

      sleep(0.01)  # Small delay to ensure time difference
      user.name = "Eve Updated"
      user.save!

      expect(user.updated_at).to be > original_updated
    end
  end

  describe "scopes (class methods)" do
    it "can query users" do
      User.create!(name: "Test1")
      User.create!(name: "Test2")

      expect(User.count).to eq(2)
    end
  end
end

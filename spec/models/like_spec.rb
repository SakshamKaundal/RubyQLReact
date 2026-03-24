# spec/models/like_spec.rb
require 'rails_helper'

RSpec.describe Like, type: :model do
  let(:user) { User.create!(name: "Liker") }
  let(:post) { user.posts.create!(title: "Post", body: "Body") }

  describe "associations" do
    it "belongs to a user" do
      like = post.likes.create!(user: user)
      expect(like.user).to eq(user)
      expect(like.user_id).to eq(user.id)
    end

    it "belongs to a post" do
      like = post.likes.create!(user: user)
      expect(like.post).to eq(post)
      expect(like.post_id).to eq(post.id)
    end
  end

  describe "attributes" do
    it "creates successfully with just user and post" do
      like = post.likes.new(user: user)
      expect(like).to be_valid
      expect(like.save!).to be true
    end

    it "requires a user" do
      like = post.likes.new(user: nil)
      expect(like).not_to be_valid
      expect(like.errors[:user]).to include("must exist")
    end

    it "requires a post" do
      like = Like.new(user: user, post: nil)
      expect(like).not_to be_valid
      expect(like.errors[:post]).to include("must exist")
    end
  end

  describe "callbacks" do
    it "creates timestamp automatically" do
      like = post.likes.create!(user: user)
      expect(like.created_at).to be_a(ActiveSupport::TimeWithZone)
    end
  end

  describe "uniqueness (optional - demonstrates testing)" do
    it "can create multiple likes on different posts by same user" do
      post2 = user.posts.create!(title: "Post 2", body: "Body 2")
      like1 = post.likes.create!(user: user)
      like2 = post2.likes.create!(user: user)

      expect(Like.count).to eq(2)
    end
  end
end

# spec/models/comment_spec.rb
require 'rails_helper'

RSpec.describe Comment, type: :model do
  let(:user) { User.create!(name: "Commenter") }
  let(:post) { user.posts.create!(title: "Post", body: "Body") }

  describe "associations" do
    it "belongs to a user" do
      comment = post.comments.create!(body: "Great post!", user: user)
      expect(comment.user).to eq(user)
      expect(comment.user_id).to eq(user.id)
    end

    it "belongs to a post" do
      comment = post.comments.create!(body: "Great post!", user: user)
      expect(comment.post).to eq(post)
      expect(comment.post_id).to eq(post.id)
    end
  end

  describe "attributes" do
    it "has a body attribute" do
      comment = post.comments.create!(body: "Great post!", user: user)
      expect(comment.body).to eq("Great post!")
    end

    it "body can be nil (no validation)" do
      comment = post.comments.create!(body: nil, user: user)
      expect(comment.body).to be_nil
    end

    it "requires a user" do
      comment = post.comments.new(body: "Nice!", user: nil)
      expect(comment).not_to be_valid
      expect(comment.errors[:user]).to include("must exist")
    end

    it "requires a post" do
      comment = Comment.new(body: "Nice!", user: user, post: nil)
      expect(comment).not_to be_valid
      expect(comment.errors[:post]).to include("must exist")
    end
  end

  describe "callbacks" do
    it "creates timestamps automatically" do
      comment = post.comments.create!(body: "Nice!", user: user)
      expect(comment.created_at).to be_a(ActiveSupport::TimeWithZone)
      expect(comment.updated_at).to be_a(ActiveSupport::TimeWithZone)
    end
  end
end

# spec/models/post_spec.rb
require 'rails_helper'

RSpec.describe Post, type: :model do
  let(:user) { User.create!(name: "Author") }

  describe "associations" do
    it "belongs to a user" do
      post = user.posts.create!(title: "Test", body: "Body")
      expect(post.user).to eq(user)
      expect(post.user_id).to eq(user.id)
    end

    it "has many comments" do
      post = user.posts.create!(title: "Test", body: "Body")
      expect(post.comments).to be_a(ActiveRecord::Associations::CollectionProxy)
    end

    it "has many likes" do
      post = user.posts.create!(title: "Test", body: "Body")
      expect(post.likes).to be_a(ActiveRecord::Associations::CollectionProxy)
    end

    it "comments belong to the post" do
      post = user.posts.create!(title: "Test", body: "Body")
      comment = post.comments.create!(body: "Great!", user: user)

      expect(comment.post).to eq(post)
      expect(comment.post_id).to eq(post.id)
    end

    it "likes belong to the post" do
      post = user.posts.create!(title: "Test", body: "Body")
      like = post.likes.create!(user: user)

      expect(like.post).to eq(post)
      expect(like.post_id).to eq(post.id)
    end

    it "destroys associated comments when post is destroyed" do
      post = user.posts.create!(title: "Test", body: "Body")
      post.comments.create!(body: "Nice!", user: user)

      expect { post.destroy }.to change { Comment.count }.by(-1)
    end

    it "destroys associated likes when post is destroyed" do
      post = user.posts.create!(title: "Test", body: "Body")
      post.likes.create!(user: user)

      expect { post.destroy }.to change { Like.count }.by(-1)
    end
  end

  describe "attributes" do
    it "has title and body attributes" do
      post = user.posts.create!(title: "My Title", body: "My Content")
      expect(post.title).to eq("My Title")
      expect(post.body).to eq("My Content")
    end

    it "title can be nil (no validation)" do
      post = user.posts.create!(title: nil, body: "Body")
      expect(post.title).to be_nil
    end

    it "body can be nil (no validation)" do
      post = user.posts.create!(title: "Title", body: nil)
      expect(post.body).to be_nil
    end

    it "requires a user_id" do
      post = Post.new(title: "Title", body: "Body")
      expect(post).not_to be_valid
      expect(post.errors[:user]).to include("must exist")
    end
  end

  describe "callbacks" do
    it "creates timestamps automatically" do
      post = user.posts.create!(title: "Test", body: "Body")
      expect(post.created_at).to be_a(ActiveSupport::TimeWithZone)
      expect(post.updated_at).to be_a(ActiveSupport::TimeWithZone)
    end

    it "updates updated_at on save" do
      post = user.posts.create!(title: "Test", body: "Body")
      original_updated = post.updated_at

      sleep(0.01)
      post.title = "Updated Title"
      post.save!

      expect(post.updated_at).to be > original_updated
    end
  end
end

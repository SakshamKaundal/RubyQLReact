# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :create_user, mutation: Mutations::CreateUser, description: "Create a new user."
    field :create_post, mutation: Mutations::CreatePost, description: "Create a new post."
    field :create_comment, mutation: Mutations::CreateComment, description: "Create a new comment."
    field :update_post, mutation: Mutations::UpdatePost, description: "Update an existing post."
    field :delete_post, mutation: Mutations::DeletePost, description: "Delete an existing post."
  end
end

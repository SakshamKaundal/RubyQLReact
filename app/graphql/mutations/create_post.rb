# frozen_string_literal: true

module Mutations
  class CreatePost < Mutations::BaseMutation
    argument :title, String, required: false
    argument :body, String, required: false
    argument :user_id, Integer, required: true

    field :post, Types::PostType, null: true
    field :errors, [ String ], null: false

    def resolve(title: nil, body: nil, user_id:)
      post = Post.new(title: title, body: body, user_id: user_id)

      if post.save
        { post: post, errors: [] }
      else
        { post: nil, errors: post.errors.full_messages }
      end
    end
  end
end

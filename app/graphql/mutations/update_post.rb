# frozen_string_literal: true

module Mutations
  class UpdatePost < Mutations::BaseMutation

    argument :id,    ID,     required: true
    argument :title, String, required: false  # optional — only update what's sent
    argument :body,  String, required: false  # optional

    field :post,   Types::PostType, null: true
    field :errors, [String],        null: false

    def resolve(id:, title: nil, body: nil)
      post = Post.find_by(id: id)

      # return early if post doesn't exist
      return { post: nil, errors: ["Post not found"] } if post.nil?

      # compact removes nil values so we only update what was actually sent
      attrs = { title: title, body: body }.compact

      if post.update(attrs)
        { post: post, errors: [] }
      else
        { post: nil, errors: post.errors.full_messages }
      end
    end
  end
end
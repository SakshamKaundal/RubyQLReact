# frozen_string_literal: true

module Mutations
  class CreateComment < Mutations::BaseMutation

    # What the client sends in
    argument :body,    String, required: true
    argument :post_id, ID,     required: true
    argument :user_id, ID,     required: true

    # What the client gets back
    field :comment, Types::CommentType, null: true
    field :errors,  [String],           null: false

    def resolve(body:, post_id:, user_id:)
      comment = Comment.new(
        body:    body,
        post_id: post_id,
        user_id: user_id
      )

      if comment.save
        { comment: comment, errors: [] }
      else
        { comment: nil, errors: comment.errors.full_messages }
      end
    end
  end
end
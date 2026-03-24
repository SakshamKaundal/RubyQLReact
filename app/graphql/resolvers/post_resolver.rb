# frozen_string_literal: true

module Resolvers
  class PostResolver < Resolvers::BaseResolver
    description "Get a single post by ID"
    type Types::PostType, null: true

    argument :id, ID, required: true

    def resolve(id:)
      Post.find_by(id: id)
    end
  end
end

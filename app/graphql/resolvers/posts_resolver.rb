# frozen_string_literal: true

module Resolvers
  class PostsResolver < Resolvers::BaseResolver
    description "Get all posts"
    type [Types::PostType], null: false

    def resolve
      Post.all
    end
  end
end

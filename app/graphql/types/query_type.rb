# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    field :users, resolver: Resolvers::UsersResolver
    field :user,  resolver: Resolvers::UserResolver
    field :posts, resolver: Resolvers::PostsResolver
    field :post,  resolver: Resolvers::PostResolver
  end
end

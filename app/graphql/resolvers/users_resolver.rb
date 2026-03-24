# frozen_string_literal: true

module Resolvers
  class UsersResolver < Resolvers::BaseResolver
    description "Get all users"

    # This tells GraphQL what this resolver returns
    type [Types::UserType], null: false

    def resolve
      User.all
    end
  end
end
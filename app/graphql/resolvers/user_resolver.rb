# frozen_string_literal: true

module Resolvers
  class UserResolver < Resolvers::BaseResolver
    description "Get a single user by ID"
    type Types::UserType, null: true

    argument :id, ID, required: true

    def resolve(id:)
      User.find_by(id: id)
    end
  end
end

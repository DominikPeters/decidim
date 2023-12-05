# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      module VoteAnonymizationHelper
        ProjectWithVoters = Struct.new(:project, :voters)

        def anonymize_votes(collection)
          # Collect all user IDs of voters who have voted on any project in the collection
          user_ids = collection.each_with_object(Set.new) do |project, ids|
            project.confirmed_orders.each { |order| ids.add(order.user.id) }
          end

          # Generate random permutation of numbers
          random_ids = (1..user_ids.size).to_a.shuffle

          # Map user IDs to random (anonymized) numbers
          user_to_random_id = user_ids.zip(random_ids).to_h

          collection.map do |project|
            voters = project.confirmed_orders.map { |order| user_to_random_id[order.user.id] }
            ProjectWithVoters.new(project, voters)
          end
        end

        module_function :anonymize_votes
      end
    end
  end
end

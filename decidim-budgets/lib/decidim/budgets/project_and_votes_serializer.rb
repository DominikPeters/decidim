# frozen_string_literal: true

module Decidim
  module Budgets
    class ProjectAndVotesSerializer < Decidim::Exporters::Serializer
      # Public: Initializes the serializer with a project and a list with anonymized IDs of all voters for that project,
      # as produced by Decidim::Budgets::Admin::VoteAnonymizationHelper.anonymize_votes.
      def initialize(project_with_anonymized_votes)
        @project_with_anonymized_votes = project_with_anonymized_votes
        @project = project_with_anonymized_votes.project
        @voters = project_with_anonymized_votes.voters
      end

      # Public: Exports a hash with the serialized data for this project.
      def serialize
        serialized_project = Decidim::Budgets::ProjectSerializer.new(@project).serialize
        # if serialized_project does not have confirmed_votes (because show_votes is disabled), add it
        serialized_project[:confirmed_votes] ||= @project.confirmed_orders_count
        serialized_project[:anonymized_voters] = @voters
        serialized_project
      end

      private

      attr_reader :project_with_anonymized_votes
      alias resource project_with_anonymized_votes

    end
  end
end

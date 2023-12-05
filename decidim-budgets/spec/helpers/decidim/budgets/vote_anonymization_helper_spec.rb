# frozen_string_literal: true

require 'spec_helper'

module Decidim::Budgets::Admin
  RSpec.describe VoteAnonymizationHelper do
    describe '.anonymize_votes' do
      let(:component) do
        created_component = create(:budgets_component)
        new_settings = created_component.settings.to_h.merge(
          "vote_rule_selected_projects_enabled" => true,
          "vote_rule_threshold_percent_enabled" => false
        )
        created_component.settings = new_settings
        created_component
      end
      
      let(:budget) { create(:budget, component: component) }
      let(:projects) { create_list(:project, 5, budget: budget) }
      let(:users) { create_list(:user, 5, :confirmed, organization: component.organization) }

      before do
        # Creating confirmed orders and line items for each project
        users.each_with_index do |user, index|
          order = create(:order, user: user, budget: budget, checked_out_at: Time.current)
          projects[0..index].each do |project|
            create(:line_item, order: order, project: project)
          end
        end
      end
      
      it 'anonymizes votes while preserving the structure' do
        anonymized_projects = described_class.anonymize_votes(projects)

        expect(anonymized_projects).to be_a(Array)
        expect(anonymized_projects.size).to eq(projects.size)

        anonymized_projects.each_with_index do |project_with_voters, index|
          expect(project_with_voters).to be_a(VoteAnonymizationHelper::ProjectWithVoters)
          expect(project_with_voters.project).to eq(projects[index])
          expect(project_with_voters.voters).to be_a(Array)

          original_voters = projects[index].line_items.map { |li| li.order.user.id }

          # Check if voters are anonymized (no repeated and within range)
          expect(project_with_voters.voters.uniq.size).to eq(project_with_voters.voters.size)
          expect(project_with_voters.voters.max).to be <= users.size
          expect(project_with_voters.voters.min).to be >= 1

          # The number of voters should be the same as the original number of voters
          expect(project_with_voters.voters.size).to eq(original_voters.size)

          # For two consecutive projects, the set of voters for the first should be a superset of the second (as a set)
          # which should be true given how we set up the votes
          if index > 0
            expect(anonymized_projects[index - 1].voters.to_set).to be_superset(project_with_voters.voters.to_set)
          end
        end
      end
    end
  end
end

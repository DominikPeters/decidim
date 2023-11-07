# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      # This command is executed when the user creates a Project from the admin
      # panel.
      class CreateProject < Decidim::Commands::CreateResource
        include ::Decidim::GalleryMethods

        fetch_form_attributes :budget, :scope, :category, :title, :description, :budget_amount, :address, :latitude, :longitude

        # Creates the project if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if @form.invalid?

          if process_gallery?
            build_gallery
            return broadcast(:invalid) if gallery_invalid?
          end

          transaction do
            create_project!
            link_proposals
            create_gallery if process_gallery?
          end

          broadcast(:ok)
        end

        private

        attr_reader :gallery

        def extra_params = { visibility: "all" }

        def resource_class = Decidim::Budgets::Project

        def create_resource
          super(soft: false)
          @attached_to = resource
        end

        def proposals
          @proposals ||= project.sibling_scope(:proposals).where(id: form.proposal_ids)
        end

        def link_proposals
          project.link_resources(proposals, "included_proposals")
        end
      end
    end
  end
end

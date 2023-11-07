# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      # This command is executed when the user changes a Project from the admin
      # panel.
      class UpdateProject < Decidim::Commands::UpdateResource
        include ::Decidim::GalleryMethods

        fetch_form_attributes :scope, :category, :title, :description, :budget_amount, :address, :latitude, :longitude

        # Initializes an UpdateProject Command.
        #
        # form - The form from which to get the data.
        # project - The current instance of the project to be updated.
        def initialize(form, resource)
          super(form, resource)
          @attached_to = project
        end

        # Updates the project if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          if process_gallery?
            build_gallery
            return broadcast(:invalid) if gallery_invalid?
          end

          transaction do
            update_resource
            link_proposals
            create_gallery if process_gallery?
            photo_cleanup!
          end

          broadcast(:ok)
        end

        private

        attr_reader :project, :form, :gallery

        def attributes = super.merge(selected_at: )

        def proposals
          @proposals ||= project.sibling_scope(:proposals).where(id: form.proposal_ids)
        end

        def link_proposals
          project.link_resources(proposals, "included_proposals")
        end

        def selected_at
          return unless form.selected

          Time.current
        end
      end
    end
  end
end

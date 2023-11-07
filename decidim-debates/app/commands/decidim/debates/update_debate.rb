# frozen_string_literal: true

module Decidim
  module Debates
    # A command with all the business logic when a user updates a debate.
    class UpdateDebate < Decidim::Commands::UpdateResource
      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the debate.
      # - :invalid if the form was not valid and we could not proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?
        return broadcast(:invalid) unless resource.editable_by?(form.current_user)

        with_events(with_transaction: true) do
          update_resource
        end

        broadcast(:ok, resource)
      end

      protected

      def extra_params = { visibility: "public-only" }

      private

      attr_reader :form

      def event_arguments
        {
          resource:,
          extra: {
            event_author: form.current_user,
            locale:
          }
        }
      end

      def attributes
        parsed_title = Decidim::ContentProcessor.parse_with_processor(:hashtag, form.title, current_organization: form.current_organization).rewrite
        parsed_description = Decidim::ContentProcessor.parse_with_processor(:hashtag, form.description, current_organization: form.current_organization).rewrite
        {
          category: form.category,
          title: {
            I18n.locale => parsed_title
          },
          description: {
            I18n.locale => parsed_description
          },
          scope: form.scope
        }
      end
    end
  end
end

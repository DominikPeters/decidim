# frozen_string_literal: true

module Decidim
  module Admin
    # Creates a newsletter and assigns the right author and
    # organization.
    class CreateNewsletter < Decidim::Commands::CreateResource
      # Initializes the command.
      #
      # form - The source fo data for this newsletter.
      # content_block - An instance of `Decidim::ContentBlock` that holds the
      #     newsletter attributes.
      # user - The User that authored this newsletter.
      def initialize(form, content_block)
        super(form)
        @content_block = content_block
      end

      private

      attr_reader :content_block

      def resource_class = Decidim::Newsletter

      def attributes
        {
          subject: form.subject,
          author: form.current_user,
          organization: form.current_organization
        }
      end

      def run_after_hooks
        ContentBlocks::UpdateContentBlock.call(form, content_block, form.current_user) do
          on(:ok) do |content_block|
            content_block.update(scoped_resource_id: resource.id)
            @content_block = content_block
          end
          on(:invalid) do
            raise "There was a problem persisting the changes to the content block"
          end
        end
      end
    end
  end
end

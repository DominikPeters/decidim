# frozen_string_literal: true

module Decidim
  module Comments
    # A command with all the business logic to delete a comment
    class DeleteComment < Decidim::Commands::DestroyResource
      private

      def invalid?
        !resource.authored_by?(current_user)
      end

      def extra_params = { visibility: "public-only" }
    end
  end
end

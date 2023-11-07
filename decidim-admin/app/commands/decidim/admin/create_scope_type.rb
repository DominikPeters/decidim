# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic when creating a scope type.
    class CreateScopeType < Decidim::Commands::CreateResource
      fetch_form_attributes :name, :organization, :plural
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      def initialize(form)
        @form = form
        @user = user
      end

      private

      def resource_class = Decidim::ScopeType
    end
  end
end

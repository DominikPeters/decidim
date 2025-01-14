# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing all pages at the admin panel.
    #
    class StaticPagesController < Decidim::Admin::ApplicationController
      include Decidim::Admin::Concerns::HasTabbedMenu
      include Decidim::Admin::ContentBlocks::LandingPage
      include Concerns::HasContentBlocks

      before_action :tos_version_formatted, only: [:index, :edit]

      helper_method :topics

      alias update_content_blocks update

      def content_block_scope
        :static_page
      end

      def scoped_resource
        @scoped_resource ||= collection.find_by(slug: params[:id])
      end

      def enforce_permission_to_update_resource
        enforce_permission_to :update, :static_page, static_page: scoped_resource
      end

      def resource_sort_url
        update_content_blocks_static_page_path(scoped_resource)
      end

      def resource_create_url(manifest_name)
        static_page_content_blocks_path(scoped_resource, manifest_name:)
      end

      def resource_content_block_cell
        "decidim/admin/static_page_content_block"
      end

      def index
        enforce_permission_to :read, :static_page
        @topics = Decidim::StaticPageTopic.where(organization: current_organization)
        @orphan_pages = collection.where(topic: nil)
      end

      def new
        enforce_permission_to :create, :static_page
        @form = form(StaticPageForm).instance
      end

      def create
        enforce_permission_to :create, :static_page
        @form = form(StaticPageForm).from_params(form_params)

        CreateStaticPage.call(@form) do
          on(:ok) do
            flash[:notice] = I18n.t("static_pages.create.success", scope: "decidim.admin")
            redirect_to static_pages_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("static_pages.create.error", scope: "decidim.admin")
            render :new
          end
        end
      end

      def edit
        enforce_permission_to :update, :static_page, static_page: page
        @form = form(StaticPageForm).from_model(page)
      end

      def update
        @page = collection.find(params[:id])
        enforce_permission_to :update, :static_page, static_page: page
        @form = form(StaticPageForm).from_params(form_params)

        UpdateStaticPage.call(page, @form) do
          on(:ok) do
            flash[:notice] = I18n.t("static_pages.update.success", scope: "decidim.admin")
            redirect_to static_pages_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("static_pages.update.error", scope: "decidim.admin")
            render :edit
          end
        end
      end

      def destroy
        enforce_permission_to :destroy, :static_page, static_page: page

        DestroyStaticPage.call(page, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("static_pages.destroy.success", scope: "decidim.admin")
            redirect_to static_pages_path
          end
        end
      end

      private

      def tab_menu_name = :admin_static_pages_menu

      def form_params
        form_params = params.to_unsafe_hash
        form_params["static_page"] ||= {}
        form_params["static_page"]["organization"] = current_organization
        form_params["static_page"]["allow_public_access"] ||= page ? page.allow_public_access : false

        return form_params unless page

        form_params["static_page"]["slug"] ||= page.slug
        form_params
      end

      def page
        @page ||= scoped_resource
      end

      def collection
        current_organization.static_pages
      end

      def tos_version
        current_organization.tos_version
      end

      def tos_version_formatted
        @tos_version_formatted ||= l(tos_version, format: :short) if tos_version.present?
      end
    end
  end
end

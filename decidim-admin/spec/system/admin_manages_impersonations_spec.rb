# frozen_string_literal: true

require "spec_helper"

describe "Admin manages impersonations" do
  let(:user) { create(:user, :admin, :confirmed, :admin_terms_accepted, organization:) }

  def navigate_to_impersonations_page
    visit decidim_admin.root_path
    click_link "Participants"
    within_admin_sidebar_menu do
      click_link "Impersonations"
    end
  end

  it_behaves_like "manage impersonations examples"
end

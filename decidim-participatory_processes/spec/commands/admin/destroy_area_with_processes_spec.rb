# frozen_string_literal: true

require "spec_helper"

describe Decidim::Commands::DestroyResource do
  subject { described_class.new(area, user) }

  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:area) { create(:area, organization:) }

  context "when a participatory process associated to a given area exist" do
    let!(:process) { create(:participatory_process, organization:, area:) }

    it "cannot be deleted" do
      expect { subject.call }.to broadcast(:has_spaces)
      expect(area.reload.destroyed?).to be false
    end
  end
end

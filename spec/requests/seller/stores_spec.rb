require "rails_helper"

RSpec.describe "Seller::Stores", type: :request do
  describe "GET /seller/stores/new" do
    let(:seller_user) { create(:seller_user) }

    before { sign_in seller_user, scope: :seller_user }

    it "returns http success" do
      get "/seller/stores/new"
      expect(response).to have_http_status(:success)
    end
  end
end

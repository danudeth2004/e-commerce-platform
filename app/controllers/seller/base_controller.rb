module Seller
  class BaseController < ::ApplicationController
    layout "seller"

    protected

      def after_signed_in_path_for(resource)
        seller_root_path
      end
  end
end

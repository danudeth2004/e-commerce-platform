module Admin
  class BaseController < ::ApplicationController
    before_action :authenticate_admin_user!
    layout "admin"

    def after_signed_in_path_for(resource)
      admin_root_path
    end
  end
end

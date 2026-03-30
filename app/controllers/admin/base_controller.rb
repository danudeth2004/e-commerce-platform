module Admin
  class BaseController < ::ApplicationController
    helper AdminHelper

    before_action :authenticate_admin_user!
    layout "admin"
  end
end

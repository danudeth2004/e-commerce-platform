# frozen_string_literal: true

module Users
  class ProfilesController < ApplicationController
    before_action :authenticate_user!

    def show
      @hide_app_header = true
      @user = current_user
    end
  end
end

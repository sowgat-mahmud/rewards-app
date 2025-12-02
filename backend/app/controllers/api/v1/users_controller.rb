module Api
  module V1
    class UsersController < ApplicationController
      before_action :set_user

      # GET /api/v1/users/:id
      def show
        render json: @user.slice(:id, :name, :email, :points_balance)
      end

      private

      def set_user
        @user = User.find(params[:id])
      end
    end
  end
end

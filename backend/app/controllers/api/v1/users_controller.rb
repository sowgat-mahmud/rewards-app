module Api
  module V1
    class UsersController < ApplicationController
      before_action :set_user, only: :show

      # GET /api/v1/users/:id
      def show
        render json: user_payload(@user)
      end

      # GET /api/v1/users/demo
      # Returns the seeded Demo User (by email)
      def demo
        user = User.find_by!(email: "demo@example.com")
        render json: user_payload(user)
      end

      private

      def set_user
        @user = User.find(params[:id])
      end

      def user_payload(user)
        user.slice(:id, :name, :email, :points_balance)
      end
    end
  end
end

class UsersController < ApplicationController
  inherit_resources

  private

    def user_params
      params.require(:user).permit(:edit)
    end
end


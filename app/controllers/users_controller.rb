class UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
    unless @user == current_user
      #redirect_to :back, :alert => "Access denied."
      redirect_back fallback_location: root_path
    end
  end

end

class RelationshipsController < ApplicationController
  before_action :logged_in_user
  before_action :load_user, only: :create
  before_action :load_relationship, only: :destroy

  def create
    current_user.follow @user
    respond_to do |format|
      format.html {redirect_to @user}
      format.js
    end
    flash[:success] = t "dictionary.flash.follow"
    redirect_to root_path
  end

  def destroy
    current_user.unfollow @relationship.followed
    respond_to do |format|
      format.html {redirect_to @user}
      format.js
    end
    flash[:success] = t "dictionary.flash.unfollow"
    redirect_to root_path
  end

  private

  # Confirms a logged-in user.
  def logged_in_user
    return if logged_in?
    store_location
    flash[:danger] = t "dictionary.flash.log_in"
    redirect_to login_path
  end

  def load_user
    @user = User.find_by id: params[:followed_id]
    return if @user
    flash[:danger] = t "dictionary.flash.not_found"
    redirect_to root_path
  end

  def load_relationship
    @relationship = Relationship.find_by id: params[:id]
    return if @relationship
    flash[:danger] = t "dictionary.flash.not_found"
    redirect_to root_path
  end
end

class UsersController < ApplicationController
  before_action :logged_in_user, except: [:show, :new, :create]
  before_action :load_user, except: [:index, :new, :create]
  before_action :correct_user, only: [:edit, :update, :following, :followers]
  before_action :admin_user, only: :destroy

  def index
    @users = User.paginate page: params[:page],
       per_page: Settings.users.paginate.per_page
  end

  def new
    @user = User.new
  end

  def show
    @microposts = @user.microposts.paginate page: params[:page],
      per_page: Settings.microposts.paginate.per_page
  end

  def create
    @user = User.new user_params
    if @user.save
      @user.send_activation_email
      flash[:info] = t "dictionary.flash.check"
      redirect_to root_url
    else
      render :new
    end
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = t "dictionary.flash.update"
      redirect_to @user
    else
      render :edit
    end
  end

  def edit; end

  # Confirms a logged-in user.
  def logged_in_user
    return if logged_in?
    store_location
    flash[:danger] = t "dictionary.flash.log_in"
    redirect_to login_path
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = t "dictionary.flash.destroy"
    redirect_to users_path
  end

  def following
    @title = "Following"
    @users = @user.following.paginate page: params[:page],
      per_page: Settings.microposts.paginate.per_page
    render :show_follow
  end

  def followers
    @title = "Followers"
    @users = @user.followers.paginate page: params[:page],
      per_page: Settings.microposts.paginate.per_page
    render :show_follow
  end

  private

  def user_params
    params.require(:user).permit :name, :email, :password, :password_confirmation
  end

  # Confirms the correct user.
  def correct_user
    load_user
    redirect_to(root_path) unless current_user? @user
  end

  # Confirms an admin user.
  def admin_user
    redirect_to(root_path) unless current_user.admin?
  end

  def load_user
    @user = User.find_by id: params[:id]
    return if @user
    flash[:danger] = t "dictionary.flash.not_found"
    redirect_to root_path
  end
end

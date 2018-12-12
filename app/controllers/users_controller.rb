class UsersController < ApplicationController
  before_action :logged_in_user, except: [:show, :new, :create]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy
  before_action :load_user, except: [:index, :new, :create]

  def index
    @users = User.paginate page: params[:page]
  end

  def new
    @user = User.new
  end

  def show; end

  def create
    @user = User.new user_params
    if @user.save
      log_in @user
      flash[:success] = t "dictionary.welcome"
      redirect_to user_path @user
    else
      render :new
    end
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = t "dictionary.update"
      redirect_to @user
    else
      render :edit
    end
  end

  def edit; end

# Confirms a logged-in user.
  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = t "dictionary.login"
      redirect_to login_path
    end
  end

   # Confirms the correct user.
  def correct_user
    load_user
    redirect_to(root_url) unless current_user? @user
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = t "dictionary.destroy"
    redirect_to users_path
  end

  private
  def user_params
    params.require(:user).permit :name, :email, :password, :password_confirmation
  end

  # Confirms an admin user.
  def admin_user
    redirect_to(root_url) unless current_user.admin?
  end

  def load_user
    @user = User.find_by id: params[:id]
    flash[:danger] = t "dictionary.not_found" if @user.nil?
    redirect_to login_path
  end
end

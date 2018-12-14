class PasswordResetsController < ApplicationController
  before_action :get_user, :valid_user, :check_expiration, only: [:edit, :update]
  def new; end

  def create
    @user = User.find_by email: params[:password_reset][:email].downcase

    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = t "dictionary.flash.reset_mail"
      redirect_to root_path
    else
      flash.now[:danger] = t "dictionary.flash.nf_mail"
      render :new
    end
  end

  def edit; end

  def update
    if params[:user][:password].blank?
      @user.errors.add(:password, t("dictionary.password_ctl.empty"))
      render :edit
    elsif @user.update_attributes(user_params)
      log_in @user
      flash[:success] = t "dictionary.password_ctl.done"
      redirect_to @user
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit :password, :password_confirmation
  end

  def get_user
    @user = User.find_by id: params[:id]
    flash[:danger] = t "dictionary.flash.not_found" if @user.nil?
  end

  # Confirms a valid user.
  def valid_user
    return if (@user && @user.activated? &&
    @user.authenticated?(:reset, params[:id]))
    redirect_to root_url
  end

  # Checks expiration of reset token.
  def check_expiration
    return if @user.password_reset_expired?
    flash[:danger] = t "dictionary.password_ctl.expired"
    redirect_to new_password_reset_url
  end
end

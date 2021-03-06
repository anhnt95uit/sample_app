class PasswordResetsController < ApplicationController
  before_action :load_user, :valid_user, :check_expiration, only: [:edit, :update]
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

  def load_user
    @user = User.find_by email: params[:email]
    return if @user
    flash[:danger] = t "dictionary.flash.not_found"
    redirect_to root_path
  end

  # Confirms a valid user.
  def valid_user
    unless (@user.activated? &&
      @user.authenticated?(:reset, params[:id]))
      redirect_to root_path
    end
  end

  # Checks expiration of reset token.
  def check_expiration
    return unless @user.password_reset_expired?
    flash[:danger] = t "dictionary.password_ctl.expired"
    redirect_to new_password_reset_path
  end
end

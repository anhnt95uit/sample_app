class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by email: params[:session][:email].downcase
    if user && user.authenticate(params[:session][:password])
      log_in user
      params[:session][:remember_me] == Settings.session.one ? remember(user) : forget(user)
      remember user
      redirect_to user
    else
      flash[:danger] = t "dictionary.danger" # Not quite right!
      render :new
    end
  end

  def destroy
    log_out if logged_in?
    log_out
    redirect_to root_path
  end
 end

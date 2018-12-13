class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by email: params[:session][:email].downcase
    if user && user.authenticate(params[:session][:password])
      log_in user
      if params[:session][:remember_me] == Settings.session.one
        remember(user)
      else
        forget(user)
      end
      remember user
      redirect_back_or user
    else
      flash[:danger] = t "dictionary.danger" # Not quite right!
      render :new
    end
  end

  def destroy
    log_out if logged_in?
    log_out
    redirect_to root_url
  end
 end

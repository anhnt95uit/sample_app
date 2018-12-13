module SessionsHelper
  def log_in user
    session[:user_id] = user.id
  end

  # Remembers a user in a persistent session.
  def remember user
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  def current_user
    if (user_id = session[:user_id])
      @current_user ||= User.find_by id: session[:user_id] if session[:user_id]
    elsif (user_id = cookies.signed[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(:remember, cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  def check_login user, params
    if user && user.authenticate(params[:session][:password])
      if user.activated?
        log_in user
        params[:session][:remember_me] == Settings.session.one ? remember(user) : forget(user)
        redirect_back_or user
      else
        message = I18n.t "dictionary.session_ctl.message1"
        message += I18n.t "dictionary.session_ctl.message2"
        flash[:warning] = message
        redirect_to root_path
      end
    else
      flash.now[:danger] = I18n.t "dictionary.flash.invalid"
      render :new
    end
  end

  def logged_in?
    current_user.present?
  end

  # Returns true if the given user is the current user.
  def current_user? user
    user == current_user
  end
  # Forgets a persistent session.

  def forget user
    user.forget
    cookies.delete :user_id
    cookies.delete :remember_token
  end

  def log_out
    forget current_user
    session.delete :user_id
    @current_user = nil
  end

  # Redirects to stored location (or to the default).
  def redirect_back_or default
    redirect_to(session[:forwarding_url] || default)
    session.delete :forwarding_url
  end

  # Stores the URL trying to be accessed.
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end
end

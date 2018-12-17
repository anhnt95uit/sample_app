class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]
  before_action :correct_user, only: :destroy
  def create
    @micropost = current_user.microposts.build(micropost_params)
    if @micropost.save
      flash[:success] = t "dictionary.flash.create_micro"
      redirect_to root_path
    else
      @feed_items = []
      render "static_pages/home"
    end
  end

  def destroy
    @micropost.destroy
    flash[:success] = t "dictionary.flash.delete_micro"
    redirect_to request.referrer || root_path
  end


  # Confirms a logged-in user.
  def logged_in_user
    return if logged_in?
      store_location
      flash[:danger] = t "dictionary.flash.log_in"
      redirect_to login_path
  end

  private

  def correct_user
      @micropost = current_user.microposts.find_by id: params[:id]
      redirect_to root_path if @micropost.nil?
  end

  def micropost_params
      params.require(:micropost).permit :content, :picture
  end
end

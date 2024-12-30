class Admin::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin
  before_action :set_user, only: [:activate_user, :deactivate_user]

  def index
    @users = User.includes(:posts) # Load users and their posts
    if user_signed_in?
      @posts = Post.includes(:comments).where("visibility = ? OR user_id = ?", 'public', current_user.id).order(created_at: :desc)
    else
      # Show only public posts to users who are not signed in
      @posts = Post.includes(:comments).where(visibility: 'public').order(created_at: :desc)
    end
    # Initialize a new post for the form
    @post = Post.new
  end

  def new
    @user = User.new
    @roles = Role.all # Assuming you have a Role model and it's associated with users
  end

  def create
    @user = User.new(user_params)
    @user.password = "password" # Set default password

    if @user.save
      # Assign roles to the user
      @user.role_ids = params[:user][:role_ids]
      flash[:notice] = "Id has been created successfully."
      redirect_to admin_managed_users_dashboard_path # Redirect to users list
    else
      @roles = Role.all
      render :new,  status: :unprocessable_entity
    end
  end

  def profile
    @user = current_user # Fetch the currently logged-in user's details
  end

  def managed_users
    @users = User.all
  end

  def activate_user
    user = User.find(params[:id])
    if user.update(active: true)
      redirect_to "/admin/managed_users"
      flash[:notice] = "Id Successfully Activated."
    else
      redirect_to "/admin/managed_users"
      flash[:alert] = "Failed to Activate"
    end
  end

  def deactivate_user
    user = User.find(params[:id])
    if user.update(active: false)
      redirect_to "/admin/managed_users"
      flash[:notice] = "Id Successfully Deactivated."

    else
      redirect_to "/admin/managed_users"
      flash[:alert] = "Failed to deactivate"
    end
  end

  private
  # Give a permit
  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :phone_number, role_ids: [])
  end

  # Fetch the user by ID
  def set_user
    @user = User.find(params[:id])
  end

  def inactive_message
    "Your account has been deactivated. Please contact support."
  end

  def ensure_admin
    unless current_user.has_role?(:admin)
      redirect_to root_path, alert: "You are not authorized to access this page."
    end
  end
end

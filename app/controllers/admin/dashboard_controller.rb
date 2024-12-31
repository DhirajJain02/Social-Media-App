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
      render :new, status: :unprocessable_entity
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

  def reports
    filter = params[:filter]

    case filter
    when 'all_users_report'
      @users_report = User
                        .left_joins(:posts, :comments, :likes)
                        .select("users.id, users.first_name, posts.title, posts.description, comments.content AS comment_content, COUNT(DISTINCT likes.id) AS likes_count")
                        .group("users.id")
                        .order("users.first_name ASC")
    when 'users_more_than_10_posts_report'
      @users_report = User
                        .left_joins(posts: [:comments, :likes])
                        .select("users.first_name, posts.title, posts.description, comments.content AS comment_content, COUNT(DISTINCT likes.id) AS likes_count")
                        .group("users.id")
                        .having("COUNT(posts.id) > ?", 10)
                        .order("users.first_name ASC")
    when 'all_posts_report' # New case for all posts report
      @posts_report = Post
                        .left_joins(:comments, :likes)
                        .select("posts.title, posts.description, comments.content AS comment_content, COUNT(DISTINCT likes.id) AS likes_count")
                        .group("posts.id")
                        .order("posts.created_at DESC")
    else
      @posts_report = Post.all # Default or other report logic
    end

    respond_to do |format|
      format.html
      format.csv { send_data generate_csv(@users_report || @posts_report), filename: "#{filter}_report_#{Date.today}.csv" }
      format.xlsx { send_data generate_xlsx(@users_report || @posts_report), filename: "#{filter}_report_#{Date.today}.xlsx" }
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

  # def generate_csv(users)
  #   CSV.generate(headers: true) do |csv|
  #     csv << ["Name", "Posts", "Comments", "Likes"]
  #     users.each do |user|
  #       csv << [user.first_name, user.posts_count, user.comments_count, user.likes_count]
  #     end
  #   end
  # end

  def generate_csv(records)
    CSV.generate(headers: true) do |csv|
      if records.first.is_a?(User)
        # User-based reports
        csv << ["First Name", "Post Title", "Post Description", "Comments Content", "Likes Count"]
        records.each do |user|
          user.posts.each do |post|
            # Loop through posts of a user and generate a row for each post
            post.comment_contents.each do |comment_content|
              csv << [
                user.first_name,
                post.title,
                post.description,
                comment_content,
                post.likes_count
              ]
            end
          end
        end
      elsif records.first.is_a?(Post)
        # Post-based reports
        csv << ["Post Title", "Post Description", "Comments Content", "Likes Count" ]
        records.each do |post|
          post.comment_contents.each do |comment_content|
            csv << [
              post.title,
              post.description,
              comment_content,
              post.likes_count

            ]
          end
        end
      end
    end
  end


  def generate_xlsx(records)
    # Initialize the workbook
    package = Axlsx::Package.new
    workbook = package.workbook

    workbook.add_worksheet(name: 'Report') do |sheet|
      if records.first.is_a?(User)
        # User-based reports
        sheet.add_row ["First Name", "Post Title", "Post Description", "Comments Content", "Likes Count"]
        records.each do |user|
          user.posts.each do |post|
            sheet.add_row [
                            user.first_name,
                            post.title,
                            post.description,
                            post.comment_contents,
                            post.likes_count
                          ]
          end
        end
      elsif records.first.is_a?(Post)
        # Post-based reports
        sheet.add_row ["Post Title", "Description", "Comments Content", "Likes Count"]
        records.each do |post|
          sheet.add_row [
                          post.title,
                          post.description,
                          post.comment_contents,
                          post.likes_count

                        ]
        end
      end
    end

    # Send the Excel file to the browser
    package.to_stream.read
  end

end

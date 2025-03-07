require "csv"

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
      flash[:notice] = "User has been created successfully."
      redirect_to admin_managed_users_dashboard_path # Redirect to users list
    else
      @roles = Role.all
      flash.now[:error] = "User could not be created."
      render :new, status: :unprocessable_entity
    end
  end

  def profile
    @user = current_user # Fetch the currently logged-in user's details
  end

  def upload_file

  end

  def upload_csv
    if params[:file].present?
      # @file_upload = params[:file]
      file = params[:file]

      if file.content_type == "text/csv" # Handle CSV files
        process_csv(file)

      elsif file.content_type == "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" # Handle Excel files
        process_excel(file)

      else
        flash.now[:alert] = "Please upload a CSV or Excel file."
        return render :'admin/dashboard/upload_file', status: :unprocessable_entity
      end
      flash[:notice] = "File uploaded successfully!"
    else
      flash[:alert] = "Please select a file to upload."
    end

    redirect_to admin_managed_users_dashboard_path
  end

  def managed_users
    @users = User.all
  end

  def delete
    @user = User.find(params[:id])
    @user.destroy
    redirect_to admin_managed_users_dashboard_path, notice: "Id deleted successfully!"
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
                        .select("users.id, users.first_name, users.last_name,
          STRING_AGG(posts.title, ', ') AS post_titles,
          STRING_AGG(posts.description, ', ') AS post_descriptions,
          STRING_AGG(comments.content, ', ') AS comment_contents,
          COUNT(DISTINCT likes.id) AS likes_count")
                        .group("users.id, users.first_name, users.last_name")
                        .order("users.first_name ASC")

    when 'users_more_than_10_posts_report'
      @users_report = User
                        .left_joins(:posts, :comments, :likes)
                        .select("users.id, users.first_name, users.last_name,
          STRING_AGG(posts.title, ', ') AS post_titles,
          STRING_AGG(posts.description, ', ') AS post_descriptions,
          STRING_AGG(comments.content, ', ') AS comment_contents,
          COUNT(DISTINCT likes.id) AS likes_count,
          COUNT(posts.id) AS post_count")
                        .group("users.id, users.first_name, users.last_name")
                        .having("COUNT(posts.id) > ?", 10)
                        .order("users.first_name ASC")

    when 'all_posts_report' # New case for all posts report
      @posts_report = Post
                        .left_joins(:comments, :likes)
                        .select("posts.id, posts.title, posts.description,
          STRING_AGG(comments.content, ', ') AS comment_contents,
          COUNT(DISTINCT likes.id) AS likes_count")
                        .group("posts.id, posts.title, posts.description")
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

  def process_csv(file)
    user_statuses = []

    # Parse CSV and create users from the CSV
    CSV.foreach(file.path, headers: true) do |row|
      # User.create!(row.to_h)
      user_data = row.to_h
      user = User.new(user_data)
      if user.save
        user_statuses << { first_name: user.first_name, last_name: user.last_name, email: user.email, status: "Success" }
      else
        user_statuses << { first_name: user_data["first_name"], last_name: user_data["last_name"], email: user_data["email"], status: "Failed: #{user.errors.full_messages.join(', ')}" }
      end
    end
    AdminMailer.upload_status_email("dhiraj.lodha@jarvis.consulting", user_statuses).deliver_later
    # UploadNotificationJob.perform_later("dhiraj.lodha@jarvis.consulting", status_details)
    user_statuses
  end

  def process_excel(file)
    status_details = []
    # Parse Excel and create users from the Excel file
    spreadsheet = Roo::Spreadsheet.open(file.path)
    spreadsheet.each_with_index do |row, index|
      next if index == 0 # Skip header row
      # User.create!(first_name: row[0], last_name: row[1], email: row[2], phone_number: row[3], password: row[4])
      user_data = { first_name: row[0], last_name: row[1], email: row[2], phone_number: row[3], password: row[4] }
      user = User.new(user_data)
      if user.save
        status_details << { first_name: user.first_name, last_name: user.last_name, email: user.email, status: 'Success' }
      else
        status_details << { first_name: user_data[:first_name], last_name: user_data[:last_name], email: user_data[:email], status: "Failed: #{user.errors.full_messages.join(', ')}" }
      end
    end
    AdminMailer.upload_status_email("dhiraj.lodha@jarvis.consulting", status_details).deliver_later
    # UploadNotificationJob.perform_later("dhirajlodha2002@gmail.com", status_details)
  end

  def generate_csv(records)
    CSV.generate(headers: true) do |csv|
      if records.first.is_a?(User)
        # User-based reports
        csv << ["User Id", "First Name", "Last Name", "Post Title", "Post Description", "Comments Content", "Likes Count"]
        records.each do |user|
          user.posts.each do |post|
            # Loop through posts of a user and generate a row for each post
            # post.comment_contents.each do |comment_content|
            csv << [user.id, user.first_name, user.last_name, post.title, post.description, post.comment_contents, post.likes.count]
            # end
          end
        end
      elsif records.first.is_a?(Post)
        # Post-based reports
        csv << ["Post Id", "Post Title", "Post Description", "Comments Content", "Likes Count"]
        records.each do |post|
          # post.comment_contents.each do |comment_content|
          csv << [post.id, post.title, post.description, post.comment_contents, post.likes_count]
          # end
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
        sheet.add_row ["User Id", "First Name", "Last Name", "Post Title", "Post Description", "Comments Content", "Likes Count"]
        records.each do |user|
          user.posts.each do |post|
            sheet.add_row [user.id, user.first_name, user.last_name, post.title, post.description, post.comment_contents, post.likes.count]
          end
        end
      elsif records.first.is_a?(Post)
        # Post-based reports
        sheet.add_row ["Post Id", "Post Title", "Description", "Comments Content", "Likes Count"]
        records.each do |post|
          # post.comment_contents.each do |comment_content|
          sheet.add_row [post.id, post.title, post.description, post.comment_contents, post.likes_count]
          # end
        end
      end
    end

    # Send the Excel file to the browser
    package.to_stream.read
  end

end

class PostsController < ApplicationController
  # before_action :find_post, only: [:like]

  def index
    if user_signed_in?
      @posts = Post.includes(:comments).where("visibility = ? OR user_id = ?", 'public', current_user.id).order(created_at: :desc)
    else
      # Show only public posts to users who are not signed in
      @posts = Post.includes(:comments).where(visibility: 'public').order(created_at: :desc)
    end

    # Initialize a new post for the form
    @post = Post.new
  end

  def home

  end

  # Show a specific post
  def show
    @post = Post.find(params[:id])
    @comments = @post.comments.order(created_at: :desc) # Sort comments by newest first
  end

  # Display the form to create a new post
  def new
    @post = Post.new
  end

  # Create a new post
  def create
    # puts current_user
    @post = current_user.posts.build(post_params)
    Rails.logger.debug "Post attributes: #{@post.inspect}" # Debugging line
    if @post.save
      redirect_to posts_path, notice: "Post created successfully!"
    else
      @posts = Post.all
      render :index, status: :unprocessable_entity
    end
  end

  # Display the form to edit an existing post
  def edit
    @post = Post.find(params[:id])
  end

  # Update an existing post
  def update
    @post = Post.find(params[:id])
    if @post.update(post_params)
      redirect_to @post, notice: "Post updated successfully!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # Delete a post
  def destroy
    @post = Post.find(params[:id])
    @post.destroy
    redirect_to posts_path, notice: "Post deleted successfully!"
  end

  def like
    @post = Post.find(params[:id])
    @post.increment!(:likes_count) # Increment the likes count

    # Respond to the request to update the like count without reloading the page
    # redirect_to posts_path

    #   new method

  end

  private


  # Strong parameters for post
  def post_params
    params.require(:post).permit(:title, :description, :visibility)
  end
end

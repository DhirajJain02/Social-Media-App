class PostsController < ApplicationController
  # Show all posts on the homepage
  def index
    @posts = Post.all
    @posts = Post.includes(:comments).all
    @post = Post.new  # Used for creating a new post directly on the index page
    # @new_post = Post.new # For rendering the post creation form
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
    @post = Post.new(post_params)
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
    redirect_to posts_path
  end


  private

  # Strong parameters for post
  def post_params
    params.require(:post).permit(:title, :description)
  end
end

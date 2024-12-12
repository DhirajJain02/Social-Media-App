class CommentsController < ApplicationController
  before_action :find_post
  before_action :find_comment, only: [:like]
  def create
    @comment = @post.comments.build(comment_params)

    if @comment.save
      # Respond with JS for inline update of comments
      respond_to do |format|
        format.html
        # format.js   # This will respond to AJAX request for inline update
      end
    else
      render "posts/show"
    end
  end

  def like
    # Increment the like count of the comment
    @comment.increment!(:like_count)

    # redirect_to post_path(@post)
    # Respond with the updated like count for the comment
    respond_to do |format|
      format.js { render :update }
    end


  end

  private
  def find_post
    @post = Post.find(params[:post_id])
  end

  def find_comment
    @comment = Comment.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:content)
  end
end


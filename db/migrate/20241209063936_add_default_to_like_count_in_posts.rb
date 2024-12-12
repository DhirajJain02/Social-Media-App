class AddDefaultToLikeCountInPosts < ActiveRecord::Migration[8.0]
  def change
    change_column_default :posts, :likes_count, 0
  end
end

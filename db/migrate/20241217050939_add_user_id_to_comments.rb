class AddUserIdToComments < ActiveRecord::Migration[8.0]
  def change
    # Step 1: Add user_id without NOT NULL constraint
    add_reference :comments, :user, foreign_key: true, null: true

    # Step 2: Create a default user if none exists
    default_user = User.first_or_create!(email: "default@example.com", password: "password123")

    # Step 3: Assign the default user ID to all existing comments
    Comment.reset_column_information
    Comment.update_all(user_id: default_user.id)

    # Step 4: Change column to enforce NOT NULL constraint
    change_column_null :comments, :user_id, false
  end
end

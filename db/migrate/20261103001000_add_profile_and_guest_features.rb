class AddProfileAndGuestFeatures < ActiveRecord::Migration[7.1]
  def change
    add_column :profiles, :monthly_goal, :integer, null: false, default: 12
    add_column :profiles, :avatar_data, :binary
    add_column :profiles, :avatar_content_type, :string
    add_column :users, :guest, :boolean, null: false, default: false
    add_column :users, :guest_expires_at, :datetime
    add_index :users, [:guest, :guest_expires_at]
  end
end

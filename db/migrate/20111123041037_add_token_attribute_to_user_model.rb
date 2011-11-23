class AddTokenAttributeToUserModel < ActiveRecord::Migration
  def change
    add_column :users, :tracker_api_token, :string
  end
end

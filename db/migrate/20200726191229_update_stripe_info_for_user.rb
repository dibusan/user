class UpdateStripeInfoForUser < ActiveRecord::Migration[5.0]
  def change
    rename_column :users, :stripe_api_key, :stripe_acc_id
  end
end

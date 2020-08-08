class AddStripeApiKeyToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :stripe_api_key, :string
  end
end

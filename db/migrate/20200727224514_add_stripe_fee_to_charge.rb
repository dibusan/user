class AddStripeFeeToCharge < ActiveRecord::Migration[5.0]
  def change
    add_column :charges, :stripe_fee, :integer
  end
end

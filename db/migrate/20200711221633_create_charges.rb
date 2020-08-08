class CreateCharges < ActiveRecord::Migration[5.0]
  def change
    create_table :charges do |t|
      t.integer :amount, required: true
      t.text :description
      t.references :from_user, foreign_key: { to_table: :users }
      t.references :to_user, foreign_key: { to_table: :users }
      t.text :stripe_data
      t.integer :state, default: Charge.states[:unprocessed]

      t.timestamps
    end
  end
end

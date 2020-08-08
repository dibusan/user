class Add < ActiveRecord::Migration[5.0]
  def change
    add_column :charges, :client_secret, :string
  end
end

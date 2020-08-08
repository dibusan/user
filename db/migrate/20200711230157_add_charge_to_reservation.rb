class AddChargeToReservation < ActiveRecord::Migration[5.0]
  def change
    add_reference :reservations, :charge, foreign_key: true
  end
end

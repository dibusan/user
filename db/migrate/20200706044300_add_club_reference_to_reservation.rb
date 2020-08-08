class AddClubReferenceToReservation < ActiveRecord::Migration[5.0]
  def change
    add_reference :reservations, :club, foreign_key: { to_table: :users }
  end
end

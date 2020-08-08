class CreatePaidReservations
  prepend SimpleCommand

  def initialize(user, data)
    @user = user
    @data = data
  end

  def call
    reservations = build_reservation_list
    amount = reservations.sum(&:price)
    stripe_fee = calculate_stripe_fee(amount)

    charge = Charge.create!(
      amount: amount,
      stripe_fee: stripe_fee,
      from_user_id: @user.id,
      to_user_id: reservations.first.club_id
    )

    s = charge.reservations.create!(reservations.map(&:attributes))
    build_response(charge)
  end

  private

  def build_response(charge)
    reservations_data = charge.reservations.map do |r|
      {
        start: r.start_date,
        end: r.end_date,
        group_size: r.size,
        price: r.price
      }
    end

    {
      reservations: reservations_data,
      processing_fee: charge.stripe_fee,
      total: charge.amount
    }
  end

  def calculate_stripe_fee(amount)
    amount /= 100
    (((amount + 0.3)/(1-(0.029)) - amount).round(2) * 100).round
  end

  def build_reservation_list
    @data.map do |r|
      r[:user_id] = @user.id
      r = Reservation.new(r)
      raise StandardError.new 'Invalid Reservation data' unless r.valid?
      r
    end
  end
end

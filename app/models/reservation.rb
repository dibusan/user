# frozen_string_literal: true

class Reservation < ApplicationRecord
  belongs_to :user
  belongs_to :club, class_name: 'User'
  belongs_to :coach, class_name: 'User', required: false
  belongs_to :charge, required: false

  validates_presence_of :start_date, :end_date, :reservation_type, :user, :club
  validate :validate_availability

  enum reservation_type: %i[lesson play]

  def validate_availability
    return if club.nil?

    avail = club.get_schedule_availability_for(start_date)
    errors[:base] << "Not enough availability. #{avail} spots requested but only #{size} left." unless avail > size
  end

  def price
    club.schedule_config.price_per_participant * size
  end

  def dto
    m_user = { id: user.id, name: user.name }
    m_club = { id: club.id, name: club.name }
    m_coach = if coach_id.nil?
                {}
              else
                { id: coach_id, name: coach.name }
              end
    {
      id: id,
      start_date: start_date,
      end_date: end_date,
      size: size,
      reservation_type: reservation_type,
      user_id: id,
      user: m_user,
      club: m_club,
      coach: m_coach
    }
  end

  def self.count_for_start_date(start_date)
    Reservation.where(start_date: start_date).sum(:size)
  end

  def self.create_batch(user, reservations_data, must_charge: true)
    # TODO: Allow create batch without charge
    if must_charge
      charge = self.create_batch_for_charge(user, reservations_data)
      self.generate_charge_response(charge)
    else
      raise StandardError.new "Reservation without charge not implemented yet"
    end
  end

  def self.generate_charge_response(charge)
    reservations_data = charge.reservations.map do |r|
      {
        start: r.start_date,
        end: r.end_date,
        group_size: r.size,
        price: r.price
      }
    end

    {
      client_secret: charge.client_secret,
      reservations: reservations_data,
      processing_fee: charge.stripe_fee
    }
  end

  def self.create_batch_for_charge(user, reservations_data)
    reservations = self.new_reservations(user, reservations_data)
    amount = reservations.sum(&:price)
    stripe_fee = Charge.calculate_stripe_fee(amount)

    client_secret = Charge.create_payment_intent(
      (amount+stripe_fee), reservations.last.club.stripe_acc_id
    )

    charge = Charge.create!(
      amount: amount,
      stripe_fee: stripe_fee,
      from_user_id: user.id,
      to_user_id: reservations.first.club_id,
      client_secret: client_secret
    )

    reservations.each do |r|
      r.charge_id = charge.id
      r.validate

      if r.errors.messages.empty?
        r.save
      else
        raise StandardError.new "Invalid reservation error: #{r.errors.full_messages}"
      end
    end

    return charge
  end

  def self.new_reservations(user, reservations_data)
    reservations_data.map do |r|
      r[:user_id] = user.id
      Reservation.new(r)
    end
  end
end

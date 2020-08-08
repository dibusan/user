# frozen_string_literal: true

class Charge < ApplicationRecord
  has_many :reservations
  belongs_to :from_user, class_name: 'User'
  belongs_to :to_user, class_name: 'User'

  enum state: %i[unprocessed payment_accepted payment_rejected refunded cancelled]

  def self.create_for_reservations(reservations, user_from, user_to)
    amount = reservations.pluck(:size).sum * user_to.schedule_config.price_per_participant
    client_secret = Charge.create_payment_intent(amount, user_to.stripe_acc_id)

    Charge.create!(
      amount: amount,
      from_user_id: user_from.id,
      to_user_id: user_to.id,
      client_secret: client_secret
    )
  end

  def self.create_payment_intent(amount, stripe_acc_id)
    Stripe::PaymentIntent.create(
      {
        payment_method_types: ['card'],
        amount: amount,
        currency: 'usd',
        on_behalf_of: stripe_acc_id,
        transfer_data: {
          destination: stripe_acc_id,
        },
      }
    ).client_secret
  end

  def self.calculate_stripe_fee(amount)
    amount /= 100
    (((amount + 0.3)/(1-(0.029)) - amount).round(2) * 100).round
  end
end

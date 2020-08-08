class PaymentJob < ApplicationJob
  queue_as :default

  def perform(charge)
    # Do something later
    payment_intent = Stripe::PaymentIntent.create({
                                                    payment_method_types: ['card'],
                                                    amount: charge.amount,
                                                    currency: 'usd',
                                                    on_behalf_of: charge.to_user.stripe_acc_id,
                                                    transfer_data: {
                                                      destination: charge.to_user.stripe_acc_id,
                                                    },
                                                  })

  end
end

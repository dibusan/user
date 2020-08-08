class CreateStripeCustomer
  prepend SimpleCommand

  def initialize(user)
    @user = user
  end

  def call
    customer = Stripe::Customer.create
    @user.update!(stripe_customer_id: customer.id)
    if @user.stripe_customer_id.nil?
      raise StandardError.new "Failed to create Stripe Customer for user #{@user.id}"
    end
  end
end

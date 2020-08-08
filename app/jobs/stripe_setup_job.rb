class StripeSetupJob < ApplicationJob
  queue_as :default

  def perform(user)
    if User.roles[user.role] == User.roles[:guest]
      CreateStripeCustomer.call(user)
    end
  end
end

class UserMailer < ApplicationMailer
  def account_confirmation_email(user)
    @user = user
    mail(to: @user.email, subject: 'Open TT Account Confirmation')
  end

  def payment_confirmation_email(user, charge)
    @user = user
    @charge = charge
    mail(to: @user.email, subject: 'Open TT Payment Confirmation')
  end

  def upcoming_reservation_email(user, reservation)
    @user = user
    @reservation = reservation
    @fmted_date = @reservation.start_date.strftime('%m/%d/%Y')
    @fmted_time = @reservation.start_date.strftime('%k:%l %p')
    mail(to: @user.email, subject: "#{@reservation.club.name} Reservation: #{@fmted_date} @ #{@fmted_time}")
  end
end

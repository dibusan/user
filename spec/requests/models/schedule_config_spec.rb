# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ScheduleConfig, type: :model do
  describe '.generate_schedule' do
    it 'generates schedule' do
      club = User.create!(name: 'Club', email: 'club@testmail.com', password: '123123', password_confirmation: '123123')
      club.create_schedule_config(
        interval_size_in_minutes: 60,
        day_start_time: DateTime.now.beginning_of_day + 8.hours,
        day_end_time: DateTime.now.beginning_of_day + 20.hours,
        availability_per_interval: 10,
        price_per_participant: 10
      )

      schedule = club.schedule_config.generate_schedule

      expect(schedule.count).to eq(7)
    end
  end
end

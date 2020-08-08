# frozen_string_literal: true

class ScheduleConfig < ApplicationRecord
  belongs_to :user
  has_many :schedule_exceptions

  validates_presence_of :interval_size_in_minutes, :day_start_time, :day_end_time, :availability_per_interval, :price_per_participant

  # Schedule Schema
  # [
  #   {
  #     :name=>"Sunday",
  #     :date=>{
  #       :year=>"2020",
  #       :month=>"7",
  #       :day=>"05"
  #     },
  #     :blocks=>[
  #       {
  #         :start=>" 8:00 am",
  #         :end=>"10:00 am",
  #         :price=>20.0,
  #         :availability=>20
  #       },
  #       ...
  #     ]
  #   },
  #   ...
  # ]
  def generate_schedule
    schedule = []

    current_date = DateTime.now
    7.times do
      blocks = []

      current_time = day_start_time

      while current_time <= day_end_time - interval_size_in_minutes.minutes
        blocks.push(gen_block(current_date, current_time))
        current_time += interval_size_in_minutes.minutes
      end

      schedule.push(gen_day(current_date, blocks))
      current_date += 1.day
    end

    schedule
  end

  private

  def gen_day(current_date, blocks)
    {
      name: current_date.strftime('%A'),
      date: date_hash(current_date),
      blocks: blocks
    }
  end

  def gen_block(date, time)
    block_start = DateTime.new(date.year, date.month, date.day, time.hour, time.min, time.sec)
    res_count = count_reservations_for_block(block_start)

    {
      start: time_str(block_start),
      end: time_str(block_start + interval_size_in_minutes.minutes),
      price: cents_to_dollar(price_per_participant),
      availability: availability_per_interval - res_count
    }
  end

  def date_hash(datetime)
    {
      year: datetime.strftime('%Y'),
      month: datetime.strftime('%-m'),
      day: datetime.strftime('%d')
    }
  end

  def time_str(datetime)
    datetime.strftime('%l:%M %P')
  end

  def cents_to_dollar(total)
    (total / 100.0)
  end

  def count_reservations_for_block(block_start)
    Reservation.where(club_id: user_id).where(start_date: block_start).sum(:size)
  end
end

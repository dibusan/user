class ScheduleException < ApplicationRecord
  belongs_to :schedule_config

  # TODO: Add validations for : all_day, availability_per_interval and price_per_participant
  validates_presence_of :start_time, :end_time, :exception_type, :schedule_config_id

  enum exception_type: [:block_interval, :modify_interval_availability, :modify_day_start_time, :modify_day_end_time,
                        :modify_price_per_person]
end

# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  belongs_to :parent, class_name: 'User', required: false
  has_many :children, dependent: :nullify, class_name: 'User', foreign_key: :parent_id
  has_many :reservations
  has_one :schedule_config

  validates_presence_of :email, :name, :password_digest
  validates_uniqueness_of :email
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validate :validate_parent_id

  enum role: [:club, :coach, :guest]

  def validate_parent_id
    errors[:base] << "Parent ID `#{parent_id}` does not exist." unless parent_id.nil? || User.exists?(id: parent_id)
  end

  def profile
    schedule = schedule_config.generate_schedule unless schedule_config.nil?

    {
      id: id,
      name: name,
      email: email,
      schedule: schedule
    }
  end

  def get_schedule_availability_for(datetime)
    100
  end

  def gen_reservations
    resp = []
    reservations.each do |r|
      resp.push(r.dto)
    end
    resp
  end

end

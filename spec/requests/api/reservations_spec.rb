# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Reservations API', type: :request do
  include ActiveSupport::Testing::TimeHelpers
  before do
    travel_to Time.new(2020, 01, 01, 00, 00, 00)
    @authorized_user = User.create!({
                                     name: 'jon doe',
                                     email: 'jd@testmail.com',
                                     password: 'jdpass',
                                     password_confirmation: 'jdpass'
                                   })
    @club = User.create!({
                           name: 'Club',
                           email: 'club@testmail.com',
                           password: '123123',
                           password_confirmation: '123123'
                         })
    @club.create_schedule_config!({
        interval_size_in_minutes: 60,
        day_start_time: DateTime.now.beginning_of_day,
        day_end_time: DateTime.now.beginning_of_day + 20.hours,
        availability_per_interval: 5,
        price_per_participant: 5
      })
  end

  let(:Authorization) { "Bearer #{JsonWebToken.encode(user_id: @authorized_user.id)}" }

  path '/current_user/reservations' do
    get 'Get all reservations for this User' do
      tags 'Reservations'

      security [{ bearer_auth: [] }]
      consumes 'application/json'
      produces 'application/json'

      response '200', 'Reservations listed successfully for current user' do
        schema '$ref' => '#/components/schemas/get_user_reservations'

        let!(:reservation) do
          start_date = Time.new(2020, 01, 01, 8, 00, 00)
          end_date = Time.new(2020, 01, 01, 10, 00, 00)
          @authorized_user.reservations.create!(
            start_date: start_date,
            end_date: end_date,
            size: 4,
            reservation_type: Reservation.reservation_types[:play],
            club_id: @club.id
          )
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['success']).to eq(true)
        end
      end
    end
  end

  path '/current_user/reservations/batch' do
    post 'Create multiple reservations at once' do
      before(:each) do
        allow(Charge).to receive(:create_payment_intent).and_return('123123')
        @club_opening_time = DateTime.new(2020, 01, 01, 8, 00, 00)
        @club_closing_time = DateTime.new(2020, 01, 01, 20, 00, 00)
        @block_one_reservation_start = @club_opening_time.to_i
        @block_one_reservation_end = (@club_opening_time + 2.hours).to_i
        @club_1 = User.create!({
                                name: 'Club1',
                                email: 'club1@testmail.com',
                                password: '123123',
                                password_confirmation: '123123'
                              })
        @club_2 = User.create!({
                                name: 'Club2',
                                email: 'club2@testmail.com',
                                password: '123123',
                                password_confirmation: '123123'
                              })
        @schedule_config_1 = @club_1.create_schedule_config!({
          interval_size_in_minutes: 120,
          day_start_time: @club_opening_time,
          day_end_time: @club_closing_time,
          availability_per_interval: 5,
          price_per_participant: 5
        })
        @schedule_config_2 =@club_2.create_schedule_config!({
          interval_size_in_minutes: 120,
          day_start_time: @club_opening_time,
          day_end_time: @club_closing_time,
          availability_per_interval: 5,
          price_per_participant: 5
        })
        start_timestamp = DateTime.new(2020, 01, 01, 8, 00, 00)
        end_timestamp = DateTime.new(2020, 01, 01, 10, 00, 00)
        @reservations =  [
          {
            start_date: start_timestamp,
            end_date: end_timestamp,
            size: 1,
            reservation_type: 'play',
            club_id: @club_2.id
          }
        ]
      end

      tags 'Reservations'

      security [{ bearer_auth: [] }]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          reservations: {
            type: :array,
            items: {
              type: :object,
              properties: {
                club_id: { type: :integer },
                start_date: { type: :string, format: :datetime },
                end_date: { type: :string, format: :datetime },
                size: { type: :integer, enum: [1, 2, 3, 4, 5] },
                reservation_type: { type: :string, enum: Reservation.reservation_types.keys },
                coach: { type: :string, enum: %w[Jordan Krishna Xi] }
              },
              required: %w[start_date end_date password reservation_type]
            }
          }
        },
        required: %w[reservations]
      }

      response '201', 'Create Reservations batch' do
        let(:body) {
          { reservations: @reservations, cc_token: 'test_token' }
        }
        run_test! do |response|
          expect(@authorized_user.reservations.last.reservation_type).to eq(@reservations.last[:reservation_type])
        end
      end

      response '201', 'Create Reservations batch from club to club.' do
        let(:body) { { reservations: @reservations, cc_token: 'test_token' } }
        let(:Authorization) { "Bearer #{JsonWebToken.encode(user_id: @club_1.id)}" }
        run_test! do
          # expect(@club_1.schedule_config.generate_schedule[0][:blocks][0][:availability]).to eq(5)
          expect(@club_2.schedule_config.generate_schedule[0][:blocks][0][:availability]).to eq(4)
        end
      end

      response '422', 'Fail Create Reservations with bad data' do
        let(:reservations) do
          [
            {
              start_date: '2020-06-28T10:00:00',
              end_date: '2020-06-28T12:00:00'
            }, {
              start_date: '2020-06-28T10:00:00',
              end_date: '2020-06-28T12:00:00'
            }
          ]
        end

        let(:body) { { reservations: reservations, cc_token: 'test_token' } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['success']).to eq(false)
        end
      end
    end
  end

  path '/current_user/reservations/{id}' do
    put 'Update Reservation' do
      tags 'Reservations'

      security [{ bearer_auth: [] }]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :id, in: :path, type: :integer

      parameter name: :reservation, in: :body, schema: {
        type: :object,
        properties: {
          start_date: { type: :string, format: :datetime },
          end_date: { type: :string, format: :datetime },
          size: { type: :integer, enum: [1, 2, 3, 4, 5] },
          reservation_type: { type: :string, enum: Reservation.reservation_types.keys },
          coach: { type: :string, enum: %w[Jordan Krishna Xi] }
        },
        required: %w[start_date end_date password reservation_type]
      }

      response '204', 'Reservation updated successfully with valid parameters' do
        let(:existing_reservation)  do
          @authorized_user.reservations.create!({
                                                 start_date: '2020-06-28T09:00:00',
                                                 end_date: '2020-06-28T11:00:00',
                                                 size: 2,
                                                 reservation_type: 'play',
                                                 club_id: @club.id
                                               })
        end
        let(:id) { existing_reservation.id }
        let(:reservation) do
          {
            start_date: '2020-06-28T08:00:00',
            end_date: '2020-06-28T10:00:00',
            size: 1,
            reservation_type: 'play',
            club_id: @club.id
          }
        end

        run_test!
      end

      response '404', 'Reservation fails update when it does not exist' do
        let(:id) { 999 }
        let(:reservation) do
          {
            start_date: '2020-06-28T08:00:00',
            end_date: '2020-06-28T10:00:00',
            size: 1,
            reservation_type: 'play',
            club_id: @club.id
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['success']).to eq(false)
          expect(data['message']).to eq('Reservation does not exist')
        end
      end
    end

    delete 'Deletes Reservation' do
      tags 'Reservations'

      security [{ bearer_auth: [] }]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :id, in: :path, type: :integer

      response '204', 'Delete Reservation successfully' do
        let(:existing_reservation) do
          @authorized_user.reservations.create!({
                                                 start_date: '2020-06-28T09:00:00',
                                                 end_date: '2020-06-28T11:00:00',
                                                 size: 2,
                                                 reservation_type: 'play',
                                                 club_id: @club.id
                                               })
        end
        let(:id) { existing_reservation.id }

        run_test!
      end
    end
  end

  path '/reservations' do
    get 'Filter reservations' do
      tags 'Reservations'

      security [{ bearer_auth: [] }]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :club_id, in: :query, type: :integer, required: true

      response '200', 'Reservations listed successfully with filter' do
        schema '$ref' => '#/components/schemas/get_user_reservations'

        let!(:reservation) do
          @authorized_user.reservations.create!(
            start_date: '2020-01-01T08:00:00',
            end_date: '2020-01-01T20:00:00',
            size: 4,
            reservation_type: Reservation.reservation_types[:play],
            club_id: @club.id
          )
        end

        let(:club_id){ @club.id }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['success']).to eq(true)
        end
      end
    end
  end
end

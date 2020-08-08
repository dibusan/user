# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Schedule Configurations API', type: :request do
  path '/current_user/scheduleConfigs' do
    let(:authorized_user) do
      User.create!({
                     name: 'jon doe',
                     email: 'jd@testmail.com',
                     password: 'jdpass',
                     password_confirmation: 'jdpass'
                   })
    end
    let(:Authorization) { "Bearer #{JsonWebToken.encode(user_id: authorized_user.id)}" }

    get 'Get the Schedule Config for the current user' do
      tags 'Schedule Configurations'

      security [{ bearer_auth: [] }]
      consumes 'application/json'
      produces 'application/json'

      response '200', 'Schedule Config retrieved successfully' do
        let!(:schedule_config)  do
          authorized_user.create_schedule_config(
            interval_size_in_minutes: 120,
            day_start_time: '08:00:00',
            day_end_time: '20:00:00',
            availability_per_interval: 20,
            price_per_participant: 2000
          )
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['success']).to eq(true)
          expect(data).to have_key('schedule_config')
          expect(data['schedule_config']['interval_size_in_minutes']).to eq(schedule_config.interval_size_in_minutes)
        end
      end
    end

    post 'Creates New Config' do
      tags 'Schedule Configurations'

      security [{ bearer_auth: [] }]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :configuration_data, in: :body, schema: {
        type: :object,
        properties: {
          interval_size_in_minutes: { type: :integer },
          day_start_time: { type: :string, format: :datetime },
          day_end_time: { type: :string, format: :datetime },
          availability_per_interval: { type: :integer },
          price_per_participant: { type: :integer }
        },
        required:
          %w[
            interval_size_in_minutes
            day_start_time
            day_end_time
            availability_per_interval
            price_per_participant
          ]
      }

      response '201', 'Schedule created successfully' do
        schema '$ref' => '#/components/schemas/resource_creation_success'

        let(:configuration_data) do
          {
            interval_size_in_minutes: 120,
            day_start_time: '08:00:00',
            day_end_time: '20:00:00',
            availability_per_interval: 20,
            price_per_participant: 200
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['success']).to eq(true)
        end
      end

      response '422', 'Schedule failed to create with missing data' do
        schema '$ref' => '#/components/schemas/resource_creation_failure'

        let(:configuration_data) { {} }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['success']).to eq(false)
          expect(data['messages']).to include("Interval size in minutes can't be blank")
          expect(data['messages']).to include("Day start time can't be blank")
          expect(data['messages']).to include("Day end time can't be blank")
          expect(data['messages']).to include("Availability per interval can't be blank")
          expect(data['messages']).to include("Price per participant can't be blank")
        end
      end
    end

    put 'Edit existing Config' do
      tags 'Schedule Configurations'

      security [{ bearer_auth: [] }]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :configuration_data, in: :body, schema: {
        type: :object,
        properties: {
          interval_size_in_minutes: { type: :integer },
          day_start_time: { type: :string, format: :datetime },
          day_end_time: { type: :string, format: :datetime },
          availability_per_interval: { type: :integer },
          price_per_participant: { type: :integer }
        }
      }

      response '204', 'Update all Config fields successfully' do
        let!(:schedule_config) do
          authorized_user.create_schedule_config(
            interval_size_in_minutes: 120,
            day_start_time: '08:00:00',
            day_end_time: '20:00:00',
            availability_per_interval: 20,
            price_per_participant: 2000
          )
        end

        let(:configuration_data) do
          {
            interval_size_in_minutes: 111,
            day_start_time: '11:11:11',
            day_end_time: '22:22:22',
            availability_per_interval: 22,
            price_per_participant: 222
          }
        end

        run_test!
      end

      response '404', 'Update Config fails when current user does not have a config' do
        let(:configuration_data) do
          {
            interval_size_in_minutes: 111,
            day_start_time: '11:11:11',
            day_end_time: '22:22:22',
            availability_per_interval: 22,
            price_per_participant: 222
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['success']).to eq(false)
          expect(data['message']).to eq('Current User does not have a Schedule to edit')
        end
      end

      response '422', 'Update Config fails when params are empty' do
        let!(:schedule_config) do
          authorized_user.create_schedule_config(
            interval_size_in_minutes: 120,
            day_start_time: '08:00:00',
            day_end_time: '20:00:00',
            availability_per_interval: 20,
            price_per_participant: 200
          )
        end

        let(:configuration_data) do
          {
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['success']).to eq(false)
          expect(data['message']).to eq('No fields to update')
        end
      end

      response '422', 'Update Config fails when params have wrong format' do
        let!(:schedule_config) do
          authorized_user.create_schedule_config(
            interval_size_in_minutes: 120,
            day_start_time: '08:00:00',
            day_end_time: '20:00:00',
            availability_per_interval: 20,
            price_per_participant: 200
          )
        end

        let(:configuration_data) do
          {
            interval_size_in_minutes: -1,
            day_start_time: '',
            day_end_time: '',
            availability_per_interval: -1,
            price_per_participant: -1
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['success']).to eq(false)
          expect(data['messages']).to include("Day start time can't be blank")
          expect(data['messages']).to include("Day end time can't be blank")

          # TODO: Set and Test rules for all the properties: interval_size_in_minutes, availability_per_interval, etc...
        end
      end
    end
  end
end

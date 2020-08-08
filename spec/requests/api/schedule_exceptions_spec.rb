require 'swagger_helper'

RSpec.describe 'Schedule Exceptions API', type: :request do
  path '/current_user/scheduleExceptions' do
    let(:authorized_user){
      User.create!({
                     name: 'jon doe',
                     email: 'jd@testmail.com',
                     password: 'jdpass',
                     password_confirmation: 'jdpass'
                   })
    }
    let(:Authorization) { "Bearer #{JsonWebToken.encode(user_id: authorized_user.id)}" }

    post 'Creates New Schedule Exception' do
      tags 'Schedule Exception'

      security [{ bearer_auth: [] }]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :exception_data, in: :body, schema: {
        type: :object,
        properties: {
          start_time: {
            type: :string,
            format: :datetime,
            description: 'DateTime string for the exception to activate for users. Example format: "2011-05-19 10:30:14"'
          },

          end_time: {
            type: :string,
            format: :datetime,
            description: 'DateTime string for the exception to expire. Example format: "2011-05-19 10:30:14"'
          },

          all_day: {
            type: :boolean,
            description: 'If true, will apply for all days from start_time to end_time (both inclusive).'
          },

          exception_type: {
            type: :string,
            enum: ScheduleException.exception_types.keys,
            description:
              'Exceptions can only be for specific developer predetermined purposes,
                the type will reflect that purpose. For more exception_type info, use "GET /static/exception_types"'
          },

          price_per_participant: {
            type: :integer,
            description: 'Only required when exception_type is "modify_price_per_person"' },

          availability_per_interval:    {
            type: :integer,
            description: 'Only required when exception_type is "modify_interval_availability"'
          },
        },
        required:
          %w(
              start_time
              end_time
              exception_type
          )
      }

      response '201', 'Schedule Exception created successfully' do
        schema '$ref' => '#/components/schemas/resource_creation_success'

        let!(:schedule_config){
          authorized_user.create_schedule_config(
            interval_size_in_minutes: 120,
            day_start_time: '08:00:00',
            day_end_time: '20:00:00',
            availability_per_interval: 20,
            price_per_participant: 200
          )
        }

        let(:exception_data){{
          start_time: "2011-05-19 10:30:14",
          end_time: "2011-05-19 10:30:14",
          exception_type: 'block_interval'
        }}

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['success']).to eq(true)
        end
      end

      response '404', 'Schedule Exception creation failed when user does not have a Schedule' do
        schema '$ref' => '#/components/schemas/resource_creation_failure'

        let(:exception_data){{
          start_time: "2011-05-19 10:30:14",
          end_time: "2011-05-19 10:30:14",
          exception_type: 0
        }}

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['success']).to eq(false)
          expect(data['message']).to eq('Cant create schedule exception if the schedule does not exists')
        end
      end

      response '422', 'Schedule Exception creation failed when data is invalid' do
        schema '$ref' => '#/components/schemas/resource_creation_failure'

        let!(:schedule_config){
          authorized_user.create_schedule_config(
            interval_size_in_minutes: 120,
            day_start_time: '08:00:00',
            day_end_time: '20:00:00',
            availability_per_interval: 20,
            price_per_participant: 200
          )
        }

        let(:exception_data){{
          start_time: "not a date",
          end_time: "not a date",
          exception_type: "",
          all_day: "asd",
          availability_per_interval: "dda",
          price_per_participant: "dda"
        }}

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['success']).to eq(false)
          expect(data['messages']).to include("Start time can't be blank")
          expect(data['messages']).to include("End time can't be blank")
          expect(data['messages']).to include("Exception type can't be blank")

          # TODO: Add validations for : all_day, availability_per_interval and price_per_participant
        end
      end

    end
  end

  path '/current_user/scheduleExceptions/{id}' do
    let(:authorized_user){
      User.create!({
                     name: 'jon doe',
                     email: 'jd@testmail.com',
                     password: 'jdpass',
                     password_confirmation: 'jdpass'
                   })
    }
    let(:Authorization) { "Bearer #{JsonWebToken.encode(user_id: authorized_user.id)}" }

    put 'Edit existing Schedule Exception for the current user' do
      tags 'Schedule Exception'

      security [{ bearer_auth: [] }]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :id, in: :path, type: :integer
      parameter name: :exception_data, in: :body, schema: {
        type: :object,
        properties: {
          start_time: {
            type: :string,
            format: :datetime,
            description: 'DateTime string for the exception to activate for users. Example format: "2011-05-19 10:30:14"'
          },

          end_time: {
            type: :string,
            format: :datetime,
            description: 'DateTime string for the exception to expire. Example format: "2011-05-19 10:30:14"'
          },

          all_day: {
            type: :boolean,
            description: 'If true, will apply for all days from start_time to end_time (both inclusive).'
          },

          exception_type: {
            type: :string,
            enum: ScheduleException.exception_types.keys,
            description:
              'Exceptions can only be for specific developer predetermined purposes,
                the type will reflect that purpose. For more exception_type info, use "GET /static/exception_types"'
          },

          price_per_participant: {
            type: :integer,
            description: 'Only required when exception_type is "modify_price_per_person"' },

          availability_per_interval:    {
            type: :integer,
            description: 'Only required when exception_type is "modify_interval_availability"'
          },
        }
      }

      response '204', 'Schedule Exception all fields updated successfully' do
        let!(:schedule_config){
          authorized_user.create_schedule_config(
            interval_size_in_minutes: 120,
            day_start_time: '08:00:00',
            day_end_time: '20:00:00',
            availability_per_interval: 20,
            price_per_participant: 200
          )
        }

        let!(:schedule_exception) {
          schedule_config.schedule_exceptions.create(
            start_time: "2011-05-19 10:30:14",
            end_time: "2011-05-19 10:30:14",
            exception_type: 'block_interval'
          )
        }

        let(:id){ schedule_exception.id }
        let(:exception_data){{
          start_time: "2222-05-19 10:30:14",
          end_time: "2222-05-19 10:30:14",
          exception_type: 'modify_day_start_time'
        }}

        run_test!
      end

      response '404', 'Schedule Exception fails to update when id is invalid' do
        let!(:schedule_config){
          authorized_user.create_schedule_config(
            interval_size_in_minutes: 120,
            day_start_time: '08:00:00',
            day_end_time: '20:00:00',
            availability_per_interval: 20,
            price_per_participant: 200
          )
        }

        let!(:schedule_exception) {
          schedule_config.schedule_exceptions.create(
            start_time: "2011-05-19 10:30:14",
            end_time: "2011-05-19 10:30:14",
            exception_type: 'block_interval'
          )
        }

        let(:id){ 999 }
        let(:exception_data){{
          start_time: "2222-05-19 10:30:14",
          end_time: "2222-05-19 10:30:14",
          exception_type: 'modify_day_start_time'
        }}

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['success']).to eq(false)
          expect(data['message']).to eq('Schedule Exception does not exist')
        end
      end

      response '422', 'Schedule Exception fails to update when no fields provided' do
        let!(:schedule_config){
          authorized_user.create_schedule_config(
            interval_size_in_minutes: 120,
            day_start_time: '08:00:00',
            day_end_time: '20:00:00',
            availability_per_interval: 20,
            price_per_participant: 200
          )
        }

        let!(:schedule_exception) {
          schedule_config.schedule_exceptions.create(
            start_time: "2011-05-19 10:30:14",
            end_time: "2011-05-19 10:30:14",
            exception_type: 'block_interval'
          )
        }

        let(:id){ schedule_exception.id }
        let(:exception_data){{}}

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['success']).to eq(false)
          expect(data['message']).to eq('No fields to update')
        end
      end

      response '422', 'Schedule Exception fails to update when fields are invalid' do
        let!(:schedule_config){
          authorized_user.create_schedule_config(
            interval_size_in_minutes: 120,
            day_start_time: '08:00:00',
            day_end_time: '20:00:00',
            availability_per_interval: 20,
            price_per_participant: 200
          )
        }

        let!(:schedule_exception) {
          schedule_config.schedule_exceptions.create(
            start_time: "2011-05-19 10:30:14",
            end_time: "2011-05-19 10:30:14",
            exception_type: 'block_interval'
          )
        }

        let(:id){ schedule_exception.id }
        let(:exception_data){{
          start_time: "not a date",
          end_time: "not a date",
          exception_type: 'something else'
        }}

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['success']).to eq(false)
          expect(data['messages']).to include("Start time can't be blank")
          expect(data['messages']).to include("End time can't be blank")
          expect(data['messages']).to include("Exception type can't be blank")
        end
      end
    end

    delete 'Delete existing Schedule Exception for the current user' do
      tags 'Schedule Exception'

      security [{ bearer_auth: [] }]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :id, in: :path, type: :integer

      response '204', 'Schedule Exception Delete successfully' do
        let!(:schedule_config){
          authorized_user.create_schedule_config(
            interval_size_in_minutes: 120,
            day_start_time: '08:00:00',
            day_end_time: '20:00:00',
            availability_per_interval: 20,
            price_per_participant: 200
          )
        }

        let!(:schedule_exception) {
          schedule_config.schedule_exceptions.create(
            start_time: "2011-05-19 10:30:14",
            end_time: "2011-05-19 10:30:14",
            exception_type: 'block_interval'
          )
        }

        let(:id){ schedule_exception.id }

        run_test!
      end

      response '404', 'Schedule Exception fails to Delete when id is invalid' do
        let!(:schedule_config){
          authorized_user.create_schedule_config(
            interval_size_in_minutes: 120,
            day_start_time: '08:00:00',
            day_end_time: '20:00:00',
            availability_per_interval: 20,
            price_per_participant: 200
          )
        }

        let!(:schedule_exception) {
          schedule_config.schedule_exceptions.create(
            start_time: "2011-05-19 10:30:14",
            end_time: "2011-05-19 10:30:14",
            exception_type: 'block_interval'
          )
        }

        let(:id){ 999 }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['success']).to eq(false)
          expect(data['message']).to eq('Schedule Exception does not exist')
        end
      end
    end
  end
end

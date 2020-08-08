# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Users API', type: :request do
  path '/users/register' do
    post 'Creates New User' do
      tags 'Users'

      # operationId 'createUser'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          name: {type: :string},
          email: {type: :string},
          password: {type: :string},
          password_confirmation: {type: :string},
          role: {type: :string, enum: User.roles.keys},
          parent_id: {type: :integer},
        },
        required: %w[name email password password_confirmation]
      }

      response '201', 'User created successfully without parent_id' do
        schema '$ref' => '#/components/schemas/registration_success'

        let(:user) do
          {
            name: 'jon doe',
            email: 'jd@testmail.com',
            password: 'jdpass',
            password_confirmation: 'jdpass'
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['success']).to eq(true)
        end
      end

      response '201', 'User created successfully with parent_id' do
        schema '$ref' => '#/components/schemas/registration_success'

        let(:parent_user) do
          User.create!({
                         name: 'the parent',
                         email: 'parent@testmail.com',
                         password: 'jdpass',
                         password_confirmation: 'jdpass'
                       })
        end

        let(:user) do
          {
            name: 'jon doe',
            email: 'jd@testmail.com',
            password: 'jdpass',
            password_confirmation: 'jdpass',
            parent_id: parent_user.id
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['success']).to eq(true)
        end
      end

      response '409', 'User FAILED to create with parent_id' do
        schema '$ref' => '#/components/schemas/registration_failure'

        let(:user) do
          {
            name: 'jon doe',
            email: 'jd@testmail.com',
            password: 'jdpass',
            password_confirmation: 'jdpass',
            parent_id: 999
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['success']).to eq(false)
          expect(data['messages']).to include('Parent ID `999` does not exist.')
        end
      end

      response '409', 'User creation failed with invalid email' do
        schema '$ref' => '#/components/schemas/registration_failure'
        let(:user) do
          {
            name: 'jon doe',
            email: 'not-an-email',
            password: 'jdpass',
            password_confirmation: 'jdpass'
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['success']).to eq(false)
          expect(data['messages']).to include('Email is invalid')
        end
      end
    end
  end

  path '/users/current_user_profile' do
    get 'Gets User information' do
      tags 'Users'

      security [{ bearer_auth: [] }]
      consumes 'application/json'
      produces 'application/json'

      response '200', 'User retrieve profile' do
        let!(:user) do
          User.create!({
                         name: 'the parent',
                         email: 'parent@testmail.com',
                         password: 'jdpass',
                         password_confirmation: 'jdpass'
                       })
        end

        let!(:schedule_config) do
          user.create_schedule_config(
            interval_size_in_minutes: 120,
            day_start_time: '08:00:00',
            day_end_time: '20:00:00',
            availability_per_interval: 20,
            price_per_participant: 2000
          )
        end

        let(:Authorization) { "Bearer #{JsonWebToken.encode(user_id: user.id)}" }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['success']).to eq(true)
          expect(data).to have_key('user')
          expect(data['user']).to have_key('name')
          expect(data['user']).to have_key('email')
          expect(data['user']).to have_key('schedule')
        end
      end
    end
  end

  path '/users/current_user' do
    get 'Gets Current User information' do
      tags 'Users'

      security [{ bearer_auth: [] }]
      consumes 'application/json'
      produces 'application/json'

      response '200', 'User retrieve profile' do
        let!(:user) do
          User.create!({
                         name: 'the parent',
                         email: 'parent@testmail.com',
                         password: 'jdpass',
                         password_confirmation: 'jdpass'
                       })
        end

        let!(:schedule_config) do
          user.create_schedule_config(
            interval_size_in_minutes: 120,
            day_start_time: '08:00:00',
            day_end_time: '20:00:00',
            availability_per_interval: 20,
            price_per_participant: 2000
          )
        end

        let(:Authorization) { "Bearer #{JsonWebToken.encode(user_id: user.id)}" }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['success']).to eq(true)
          expect(data).to have_key('user')
          expect(data['user']).to have_key('id')
          expect(data['user']).to have_key('name')
          expect(data['user']).to have_key('email')
          expect(data['user']).to have_key('schedule')
        end
      end
    end
  end

  path '/users/current_user/link_stripe_acc' do
    put 'Adds Stripe Account Token to Current User' do
      tags 'Users'

      security [{ bearer_auth: [] }]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :stripe_acc_id, in: :query, type: :string, required: true

      response '204', 'Linked Stripe Account to User' do
        let!(:user) do
          User.create!({
                           name: 'the parent',
                           email: 'parent@testmail.com',
                           password: 'jdpass',
                           password_confirmation: 'jdpass'
                       })
        end
        let(:Authorization) { "Bearer #{JsonWebToken.encode(user_id: user.id)}" }

        let(:stripe_acc_id){ '1234567890' }

        run_test! do
          user.reload
          expect(user.stripe_acc_id).to eq(stripe_acc_id)
        end
      end

    end
  end

  path '/users/{id}' do
    get 'Get User by ID' do
      tags 'Users'

      security [{ bearer_auth: [] }]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :id, in: :path, type: :integer

      response '200', 'User profile retrieved successfully' do
        let(:user) do
          User.create!({
                         name: 'jon doe',
                         email: 'jd@testmail.com',
                         password: 'jdpass',
                         password_confirmation: 'jdpass'
                       })
        end
        let(:Authorization) { "Bearer #{JsonWebToken.encode(user_id: user.id)}" }
        let(:id) { user.id }
        run_test! do
          data = JSON.parse(response.body)
          expect(data['success']).to eq(true)
          expect(data).to have_key('user')
          expect(data['user']).to have_key('name')
        end
      end
    end

    put 'Edits existing User' do
      tags 'Users'

      security [{ bearer_auth: [] }]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :id, in: :path, type: :integer
      parameter name: :user_update, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          email: { type: :string },
          parent_id: { type: :integer }
        }
      }

      response '204', 'Update all User fields successfully' do
        let(:parent_user) do
          User.create!({
                         name: 'the parent',
                         email: 'parent@testmail.com',
                         password: 'jdpass',
                         password_confirmation: 'jdpass'
                       })
        end

        let(:parent_user_2) do
          User.create!({
                         name: 'the parent 2',
                         email: 'parent2@testmail.com',
                         password: 'jdpass',
                         password_confirmation: 'jdpass'
                       })
        end

        let(:user) do
          User.create!({
                         name: 'jon doe',
                         email: 'jd@testmail.com',
                         password: 'jdpass',
                         password_confirmation: 'jdpass',
                         parent_id: parent_user.id
                       })
        end

        let(:user_update) do
          {
            name: 'updated jon',
            email: 'updated-jd@testmail.com',
            parent_id: parent_user_2.id
          }
        end
        let(:id) { user.id }
        let(:Authorization) { "Bearer #{JsonWebToken.encode(user_id: user.id)}" }

        run_test!
      end

      response '404', 'Update fails with non-existent user id' do
        let(:user) do
          User.create!({
                         name: 'jon doe',
                         email: 'jd@testmail.com',
                         password: 'jdpass',
                         password_confirmation: 'jdpass'
                       })
        end

        let(:user_update) do
          {
            name: 'updated jon',
            email: 'updated-jd@testmail.com'
          }
        end
        let(:id) { 999 }
        let(:Authorization) do
          "Bearer #{JsonWebToken.encode(user_id: user.id)}"
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['success']).to eq(false)
          expect(data['message']).to eq('User does not exist')
        end
      end

      response '422', 'Failed edit on empty name, bad email and non-existent parent_id' do
        let(:parent_user) do
          User.create!({
                         name: 'the parent',
                         email: 'parent@testmail.com',
                         password: 'jdpass',
                         password_confirmation: 'jdpass'
                       })
        end

        let(:parent_user_2) do
          User.create!({
                         name: 'the parent 2',
                         email: 'parent2@testmail.com',
                         password: 'jdpass',
                         password_confirmation: 'jdpass'
                       })
        end

        let(:user) do
          User.create!({
                         name: 'jon doe',
                         email: 'jd@testmail.com',
                         password: 'jdpass',
                         password_confirmation: 'jdpass',
                         parent_id: parent_user.id
                       })
        end

        let(:user_update) do
          {
            name: '',
            email: 'not-an-email',
            parent_id: 999
          }
        end
        let(:id) { user.id }
        let(:Authorization) { "Bearer #{JsonWebToken.encode(user_id: user.id)}" }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['success']).to eq(false)
          expect(data['messages']).to include('Email is invalid')
          expect(data['messages']).to include("Name can't be blank")
          expect(data['messages']).to include('Parent ID `999` does not exist.')
        end
      end

      response '422', 'Failed edit when no params passed' do
        let(:user) do
          User.create!({
                         name: 'jon doe',
                         email: 'jd@testmail.com',
                         password: 'jdpass',
                         password_confirmation: 'jdpass'
                       })
        end
        let(:user_update) { {} }
        let(:id) { user.id }
        let(:Authorization) { "Bearer #{JsonWebToken.encode(user_id: user.id)}" }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['success']).to eq(false)
          expect(data['message']).to eq('No fields to update')
        end
      end
    end

    delete 'Deletes existing User' do
      tags 'Users'

      security [{ bearer_auth: [] }]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :id, in: :path, type: :integer

      response '204', 'Delete User successfully' do
        let(:user) do
          User.create!({
                         name: 'jon doe',
                         email: 'jd@testmail.com',
                         password: 'jdpass',
                         password_confirmation: 'jdpass'
                       })
        end

        let(:id) { user.id }
        let(:Authorization) { "Bearer #{JsonWebToken.encode(user_id: user.id)}" }

        run_test!
      end

      response '404', 'Delete User fails when user does not exist' do
        let(:user) do
          User.create!({
                         name: 'jon doe',
                         email: 'jd@testmail.com',
                         password: 'jdpass',
                         password_confirmation: 'jdpass'
                       })
        end

        let(:id) { 999 }
        let(:Authorization) { "Bearer #{JsonWebToken.encode(user_id: user.id)}" }

        run_test!
      end
    end
  end
end

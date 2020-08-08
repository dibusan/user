# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Authenticate User', type: :request do
  path '/authenticate' do
    post 'Create user token' do
      tags 'Authentication'

      consumes 'application/json'
      produces 'application/json'

      parameter name: :user_credentials, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string },
          password: { type: :string }
        }
      }

      response '200', 'Get a token for user authentication' do
        let!(:user) do
          User.create!({
                         name: 'jon doe',
                         email: 'jd@testmail.com',
                         password: 'jdpass',
                         password_confirmation: 'jdpass'
                       })
        end

        let(:user_credentials) do
          {
            email: 'jd@testmail.com',
            password: 'jdpass'
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
        end
      end

      response '401', 'Authorization failed with bad credentials' do
        let!(:user) do
          User.create!({
                         name: 'jon doe',
                         email: 'jd@testmail.com',
                         password: 'jdpass',
                         password_confirmation: 'jdpass'
                       })
        end

        let(:user_credentials) do
          {
            email: 'jd@testmail.com',
            password: 'not the password'
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['error']).to include('User_authentication invalid credentials')
        end
      end
    end
  end
end

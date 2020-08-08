# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Quick Auth', type: :request do
  path '/quickauth/user1' do
    get 'Get User token' do
      tags 'QuickAuth'

      consumes 'application/json'
      produces 'application/json'

      response '401', 'Get user token' do
        run_test!
      end
    end
  end

  path '/quickauth/club1' do
    get 'Get User token' do
      tags 'QuickAuth'

      consumes 'application/json'
      produces 'application/json'

      response '401', 'Get club token' do
        run_test!
      end
    end
  end
end

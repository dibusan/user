# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.swagger_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under swagger_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a swagger_doc tag to the
  # the root example_group in your specs, e.g. describe '...', swagger_doc: 'v2/swagger.json'
  config.swagger_docs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'API V1',
        version: 'v1'
      },
      components: {
        securitySchemes: {
          bearer_auth: {
            type: :http,
            scheme: :bearer
          }

        },
        schemas: {
          resource_creation_success: {
            type: :object,
            properties: {
              success: { type: :boolean },
              newId: { type: :integer }
            }
          },
          resource_creation_failure: {
            type: :object,
            properties: {
              success: { type: :boolean },
              messages: {
                type: :array,
                items: { type: :string }
              }
            }
          },
          registration_success: {
            type: :object,
            properties: {
              success: { type: :boolean },
              newUserId: { type: :integer }
            }
          },
          registration_failure: {
            type: :object,
            properties: {
              success: { type: :boolean },
              messages: {
                type: :array,
                items: { type: :string }
              }
            }
          },
          get_user_reservations: {
            type: :object,
            properties: {
              success: { type: :boolean },
              reservations: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    id: { type: :integer },
                    start_date: { type: :datetime },
                    end_date: { type: :datetime },
                    size: { type: :integer },
                    reservation_type: {
                      type: :string,
                      enum: Reservation.reservation_types.keys
                    },
                    user_id: {
                        type: :integer,
                        description: 'ALERT! This is deprecated, will be removed soon. Use reservations[0].user.id instead'
                    }, # TODO: Deprecate!
                    user: {
                      type: :object,
                      properties: {
                        id: { type: :integer },
                        name: { type: :string }
                      }
                    },
                    coach_id: { type: :integer },
                    coach: {
                      type: :object,
                      properties: {
                        id: { type: :integer },
                        name: { type: :string }
                      }
                    },
                    club_id: { type: :integer },
                    club: {
                      type: :object,
                      properties: {
                        id: { type: :integer },
                        name: { type: :string }
                      }
                    }
                  },
                  required: %i[id start_date end_date size reservation_type user_id user club]
                }
              }
            },
            required: %i[success reservations]
          }
        }
      },
      paths: {},
      servers: [
        {
          url: 'http://{defaultHost}',
          variables: {
            defaultHost: {
              default: 'localhost:3000'
            }
          }
        },
        {
          url: 'https://{defaultHost}',
          variables: {
            defaultHost: {
              default: 'localhost:3000'
            }
          }
        },
        {
          url: 'https://nameless-spire-32644.herokuapp.com/'
        }
      ]
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The swagger_docs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.swagger_format = :yaml
end

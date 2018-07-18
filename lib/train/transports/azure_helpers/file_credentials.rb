require 'inifile'
require 'train/transports/azure_helpers/file_parser'
require 'train/transports/azure_helpers/subscription_number_file_parser'
require 'train/transports/azure_helpers/subscription_id_file_parser'

module Train
  module Transports
    module AzureHelpers
      class FileCredentials
        DEFAULT_FILE = ::File.join(Dir.home, '.azure', 'credentials')

        def self.parse(subscription_id: nil, credentials_file: DEFAULT_FILE, **_)
          credentials     = IniFile.load(::File.expand_path(credentials_file))
          subscription_id = parser(subscription_id, ENV['AZURE_SUBSCRIPTION_NUMBER'], credentials).subscription_id
          creds(subscription_id, credentials)
        end

        def self.parser(subscription_id, subscription_number, credentials)
          if subscription_id
            SubscriptionIdFileParser.new(subscription_id, credentials)
          elsif !subscription_number.nil?
            SubscriptionNumberFileParser.new(subscription_number.to_i, credentials)
          else
            FileParser.new(credentials)
          end
        end

        def self.creds(subscription_id, credentials)
          {
            subscription_id: subscription_id,
            tenant_id:       credentials[subscription_id]['tenant_id'],
            client_id:       credentials[subscription_id]['client_id'],
            client_secret:   credentials[subscription_id]['client_secret']
          }
        end
      end
    end
  end
end

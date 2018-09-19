# encoding: utf-8
# frozen_string_literal: true

require 'azure_graph_rbac'

# Wrapper class for ::Azure::GraphRbac::Profiles::Latest::Client allowing custom configuration,
# for example, defining additional settings for the ::MsRestAzure::ApplicationTokenProvider.
class GraphRbac
  def initialize
    @auth_endpoint = MsRestAzure::AzureEnvironments::AzureCloud.active_directory_endpoint_url
    @api_endpoint = MsRestAzure::AzureEnvironments::AzureCloud.active_directory_graph_resource_id
  end

  def client(credentials)
    provider = ::MsRestAzure::ApplicationTokenProvider.new(
      credentials[:tenant_id],
      credentials[:client_id],
      credentials[:client_secret],
      settings,
    )
    credentials[:credentials] = ::MsRest::TokenCredentials.new(provider)
    credentials[:base_url] = @api_endpoint
    ::Azure::GraphRbac::Profiles::Latest::Client.new(credentials)
  end

  def settings
    client_settings = MsRestAzure::ActiveDirectoryServiceSettings.get_azure_settings
    client_settings.authentication_endpoint = @auth_endpoint
    client_settings.token_audience = @api_endpoint
    client_settings
  end
end

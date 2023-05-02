require "google/apis/gmail_v1"
require "googleauth"

class GoogleService
  APPLICATION_NAME = 'FB Acceptance Tests'.freeze
  SCOPE = [Google::Apis::GmailV1::AUTH_GMAIL_MODIFY].freeze

  def authenticated_service
    service = Google::Apis::GmailV1::GmailService.new
    service.client_options.application_name = APPLICATION_NAME
    service.authorization = authorize
    service
  end

  def authorize
    creds = Google::Auth::UserRefreshCredentials.new(credentials)
    creds.refresh_token = ENV['GOOGLE_REFRESH_TOKEN']
    creds.fetch_access_token!
    creds
  end

  def credentials
    {
      client_id: ENV['GOOGLE_CLIENT_ID'],
      client_secret: ENV['GOOGLE_CLIENT_SECRET'],
      scope: SCOPE,
      additional_parameters: { 'access_type' => 'offline' }
    }
  end
end

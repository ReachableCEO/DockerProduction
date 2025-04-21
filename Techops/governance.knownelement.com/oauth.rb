# Configure OAuth integration with Cloudron
if ENV['CLOUDRON_OIDC_IDENTIFIER'] && Rails.env.production?
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :openid_connect, {
      name: :cloudron,
      scope: [:openid, :email, :profile],
      response_type: :code,
      uid_field: 'sub',
      discovery: true,
      client_options: {
        identifier: ENV['CLOUDRON_OIDC_CLIENT_ID'],
        secret: ENV['CLOUDRON_OIDC_CLIENT_SECRET'],
        redirect_uri: "https://#{ENV['CLOUDRON_APP_DOMAIN']}/oauth/callback",
        port: 443,
        scheme: 'https',
        host: "#{ENV['CLOUDRON_APP_DOMAIN']}",
        discovery_document: ENV['CLOUDRON_OIDC_IDENTIFIER']
      },
      client_auth_method: 'secret_basic'
    }
  end

  # Map additional user attributes from Cloudron OIDC
  OmniAuth::Strategies::OAuth2.class_eval do
    def callback_url
      full_host + script_name + callback_path
    end
  end
end
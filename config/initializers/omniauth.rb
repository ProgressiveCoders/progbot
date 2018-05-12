Rails.application.config.middleware.use OmniAuth::Builder do
  provider :slack, ENV['SLACK_CLIENT_ID'], ENV['SLACK_CLIENT_SECRET'], scope: ['users:read','users:read.email'], team: 'T1KR8AG7J'
end

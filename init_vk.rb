configure :development do
  config_path = File.join("config", "oauth.local.yml")

  # в случае если тестируем локально, то убираем проверку сертификата
  # иначе были сложности
  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
end

configure :production do
  config_path = File.join("config", "oauth.yml")
end

if File.exists?(config_path)
  oauth_settings = YAML.load(File.read(config_path))

  if oauth_settings['vkontakte']
    ENV['API_KEY']    ||= oauth_settings['vkontakte']['api_key']
    ENV['API_SECRET'] ||= oauth_settings['vkontakte']['api_secret']
  end

  use OmniAuth::Builder do
    if ENV['API_KEY']
      provider :vkontakte, ENV['API_KEY'], ENV['API_SECRET'],
        :scope => 'friends,audio,photos', :display => 'popup'
    end
  end
end

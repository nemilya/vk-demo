# by default
config_path = File.join("config", "oauth.yml")

configure :development do
  # в режиме разрабокти используем oauth.local.yml конфиг файл
  config_path = File.join("config", "oauth.local.yml")

  # убираем проверку сертификата иначе были сложности
  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
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

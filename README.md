Демонстрация доступа к VK API через Ruby
========================================

Работающее демо: http://vk-demo.cloudfoundry.com/


Технологии
----------

* [Ruby](http://ruby-lang.org) - язык программирования Ruby
* [CloudFoundry](http://cloudfoundry.com/) - быстрое развёртывание Ruby приложений
* [Bootstrap](http://twitter.github.com/bootstrap/) - быстрое css оформление от Twitter
* [Sinatra](http://sinatraruby.ru/) - минималистичный веб фреймворк на Ruby
* [omniauth](https://github.com/intridea/omniauth) - универсальная система авторизации
* [omniauth-vkontakte](https://github.com/mamantoha/omniauth-vkontakte) - модуль для OmniAuth для авторизации в ВКонтакте
* [vkontakte_api](https://github.com/7even/vkontakte_api/blob/master/README.md) - Ruby обёртка для API функций ВКонтакте


Принцип работы
--------------

Веб-приложение работает на сервисе "cloudfoundry.com", на базе Sinatra ruby-фреймворка.

Для работы веб-приложения было создано Приложение в системе ВКонтакте. 

Веб приложение использует Omniauth библиотеку для авторизации, и vkontakte модуль для авторизации с VK.

Модуль авторизации после успешной авторизации предоставляет "токен", который можно использовать для работы
с Open API который предоставляется Vkontakte. Для работы с этим API используется гем vkontakte_api.


Для того чтобы стартовать свой экземпляр демо приложения необходимо:

* скачать приложение локально (с GitHub)
* создать приложение ВК (указав будущий URL вашего демо-сайта)
* получить конфигурационные данные (ид, секретный код)
* создать аккаунт на CloudFoundry
* прописать в конфиг файле omniauth настройки для VK приложения
* разместить приложение на CloudFoundry


Структура папок
---------------

    /config -- конфигурационные данные для библиотеки авторизации OmniAuth
    /public -- открытая для веб-папка - css, js, картинки
    /vendor -- созданная `bundle package` локальные версии библиотек
    /views -- шаблоные отображения для `Sinatra`
    app.rb -- веб приложение на базе Sinatra
    init_vk.rb -- инициализация VKontakte настроект для OmniAuth
    README.md -- тестовый файл с описанием, в формате Markdown
    Gemfile -- список требуемых для приложения библиотек (для Bundler)
    Gemfile.lock -- "слепок" версий библиотек, на которых приложение работает


Подробное описание
------------------

Стартовым файлом является файл `app.rb` в нём подгружаются требуемые библиотеки.

Далее включается поддержка сессий для веб приложения:

``` ruby
enable :sessions
```

Подключается файл настройки Omniauth (это локальный файл `init_vk.rb`):

``` ruby
require 'init_vk'
```

В файле `init_vk.rb` проверяется наличие конфигурационного файла
`config/oauth.yml` - если он существует, то он загружается и обрабатывается
парсером YAML формата, который возвращает хэш массив (массив ключ, значения).

Проверяется наличие секции "vkontakte", и выставлюятся переменные окружения 
согласно настройкам VK приложения - API_KEY и API_SECRET.

Далее происходит инициализация соответсвующего провайдера в блоке:

``` ruby
use OmniAuth::Builder
```

Инициализируется провайдер авторизации через ВКонтакте:

``` ruby
provider :vkontakte, ENV['API_KEY'], ENV['API_SECRET'],
  :scope => 'friends,audio,photos', :display => 'popup'
```


Передаются ключ, и секретный код, указываются права доступа, которые будет запрашивать
приложение.

После этого автоматически регистрируется "урл" - '/auth/vkontakte', здесь "vkontakte" - это
провайдер который мы зарегистрировали внутри блока `OmniAuth::Builder`.

Возвращаясь к `app.rb`, это синатра приложение, и в нём описываются роуты (маршруты),
которые может принимать это веб-приложение, описываются они в формате:

``` ruby
get '/урл' do
  "результат выполнения будет выдан браузеру"
end
```

При получении входящего запроса - Синатра смотрит все зарегистрированные роуты,
и первый подходящий под запрос - будет выполнен, результат выполнения будет
возвращён браузеру.

В нашем приложении зарегистрировано 3 роута:

``` ruby
get '/' do
  ...
end

get '/logout' do
  ...
end

get '/auth/:name/callback' do
  ...
end
```

Первый обрабатывает запрос на корневую страницу.

Второй обрабатывает запрос на выход из приложения.

Третий обрабатывает callback запрос - когда человек авторизовался ВКонтакте.
(`:name` - на этом месте будет название провайдера через который произошла авторизация,
название подставляется OmniAuth автоматически, и в нашем случае это будет vkontakte)

В блоке корневой страницы происходит отрисовка шаблона `index.erb`,
находящегося в папке 'views/'.

`erb` - это парсер, параметром является название шаблона:

``` ruby
erb :index
```

В блоке `'/logout'` - происходит очистка сессии.

Блок `'/auth/:name/callback'` - вызывается автоматически после авторизации,
и OmniAuth записывает в переменную окружения `omniauth.auth` результат
авторизации пользователя.

Мы берём оттуда токен (неоходим для работы с API ВКонтакте), и имя пользователя
и сохраняем эти значения в сессии:

``` ruby
session[:token] = auth_hash[:credentials][:token]
session[:name] = auth_hash[:info][:name]
```

После чего делаем редирект на корневую страницу:

``` ruby
redirect '/'
```

Надо отметить, что перед роутами есть блок `before`:

``` ruby
before do
  @app = VkontakteApi::Client.new(session[:token]) if session[:token]
end
```

Блок `before` в Sinatra выполяется перед каждым выполнением Роутов.

В нём инициализируется переменная `@app`, если выставлен в сессии токен доступа.

Эта переменная будет исользуется во `вьюшках`.

В папке `views` есть файл `layout.erb` и Синатра по умолчанию использует файл
с этим названием для отрисовки страницы, и внутри этого файла блок:

``` ruby
<%= yield %>
```

В этом место будет выведен результат выполнения блока Роута, например, 
в случае роута на корневую страницу, на этом место будет выведен результат
выполенния `index.erb` файла.

`index.erb` содержит условие, что если переменная `@app` проинициаилизрована
то выводится erb файл `vk_api_demo.erb`:

``` erb
<% if @app %>
  <%= erb :vk_api_demo %>
<% end %>
```

И внутри этого файла находятся запросы к VK API.



Создание приложения VK
----------------------

Заходим на раздел для разработчиков http://vk.com/developers.php

Нажимаем "Создать приложение" http://vk.com/editapp?act=create

Указываем "Название" и выбираем "Веб-сайт", указываем адрес сайта:

Адрес сайта: http://vk-test.cloudfoundry.com

Базовый домен: http://vk-test.cloudfoundry.com

Внимание! vk-test.cloudfoundry.com - может быть занят, поэтому предварительно 
проверьте что домен 3го уровня не занят.

cloudfoundry.com - это сервис где будет размещёно веб-приложение взаимодействующее
с ВКонтактом.

После регистрации - получаем идентификатор "ID приложения" и секретный ключ "Защищенный ключ".

Эти два значения необходимо прописать в файле `config/oauth.yml`, предварительно скопировав
его из файла `oauth.yml.template`, в параметры "api_key" и "api_secret" соответственно.

После этого - необходимо разместить приложение на хостинге.

Запуск приложения локально
--------------------------

При разработке на OS X можно запустить приложение локально с помощью [Pow](http://pow.cx/):

``` bash
$ cd path/to/app     # переходим в папку приложения
$ gem install powder # при необходимости ставим powder (обертка для pow)
$ powder link        # устанавливаем приложение в pow
$ powder open        # открываем приложение в браузере
```

В этом случае в [настройках приложения на ВКонтакте](http://vk.com/apps?act=settings) нужно вписать соответствующие домен и адрес сайта.

Локальное тестирование
----------------------

ВКонтакте не позволяет указывать `localhost`, и тестировать таким образом приложение локально.

Для решения этой проблемы неоходимо создать хост.

На win32 машине это делается с помощью редактирования файла:
`{WINDOWS_папка}\system32\drivers\etc\hosts`

Добавляется строка, например, для домена `local.vcap.me`:

    127.0.0.1        local.vcap.me

Далее, если наше приложение будет работать на порту `4567`, тогда при регистрации в полях
"Адрес сайта" и "Базовый домен" указываем: `http://local.vcap.me:4567`.


Стартуем веб-приложение:

    ruby app.rb -p 4567 -o local.vcap.me

Заходим браузером на `http://local.vcap.me:4567`, и попытка авторизации должна быть 
успешной.


Размещение приложения на CloudFoundry
-------------------------------------

http://docs.cloudfoundry.com/frameworks/ruby/ruby.html
http://docs.cloudfoundry.com/frameworks/ruby/sinatra.html

Регистрируемся на cloudfoundry.com

Устанавливаем gem - vmc:

``` bash
$ gem install vmc
```

Авторизуемся:

``` bash
$ vmc login
```

Указываем емейл и пароль - полученный после регистрации.

Перед размещение на CloudFoundry необходимо локально упаковать требуемые гемы.

Делаем команду Бандлера - упаковка:

``` bash
$ bundle package
```

Появляется папка `vendor/cache` в которой сохранены все трубуемые для работы
приложения библиотеки.

Сейчас готовы к размещению на сервис, выполняем команду:

``` bash
$ vmc push vk-test
```

Здесь `vk-test` это название приложение, и оно будет соответствовать доменному
имени 3го уровня, то есть `vk-test.cloudfoundry.com` и на это доменное имя
необходимо настраивать Приложение VK для авторизации.

Приложение будет взято из текущей папки, должно определиться как Sinatra. 
Внешние сервисы не используем. Если всё ок - то должно стратовать.

Если ошибка, то получение логов командой:

``` bash
$ vmc logs vk-test
```

Где `vk-test` - название приложения.

После модификаций файлов, повторное размещение уже для созданного приложения,
выполняется по команде `update`:

``` bash
$ vmc update vk-test
```

Должны обновиться файлы либо добавиться новые, остановка приложения и запуск.

Если всё успешно, то набрав в браузере `http://vk-test.cloudfoundry.com`
вы должны увидеть ссылку для авторизации, после авторизации - список тестовых
API команд.

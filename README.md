Демонстрация доступа к VK API через Ruby
========================================

Создание приложения VK
----------------------

Заходим на раздел для разработчиков http://vk.com/developers.php

Нажимаем "Создать приложение" http://vk.com/editapp?act=create

Указываем "Название" и выбираем "Веб-сайт", указываем адрес сайта:

Адрес сайта: http://vk-test.cloudfoundry.com

Базовый домен: http://cloudfoundry.com

Внимание! vk-test.cloudfoundry.com - может быть занят, поэтому предварительно 
проверьте что домен 3го уровня не занят.

cloudfoundry.com - это сервис где будет размещёно веб-приложение взаимодействующее
с ВКонтактом.

После регистрации - получаем идентификатор "ID приложения" и секретный ключ "Защищенный ключ".

Эти два значения неоходимо прописать в файле `config/oauth.yml` предварительно скопирова
его из файла `oauth.yml.template`, в параметры "api_key" и "api_secret" соответственно.

После этого - необходимо разместить приложение на хостинге.



Размещение приложения на CloudFoundry
-------------------------------------

http://docs.cloudfoundry.com/frameworks/ruby/ruby.html
http://docs.cloudfoundry.com/frameworks/ruby/sinatra.html

Регистрируемся на cloudfoundry.com

Устанавливаем gem - vmc:

    gem install vmc

Авторизуемся:

    vmc login


Указываем емейл и пароль - полученный после регистрации.

Перез размещение на CloudFoundry необходимо локально упаковать требуемые гемы.

Делаем команду упаковки Бандлера:

    bandle package

Появляется папка `vendor/cache` в которой сохранены все трубуемые для работы
приложения библиотеки.

Сейчас готовы к размещению на сервис, выполняем команду:

    vmc push vk-test

Здесь `vk-test` это название приложение, и оно будет соответствовать доменному
имени 3го уровня, то есть `vk-test.cloudfoundry.com` и на это доменное имя
необходимо настраивать Приложение VK для авторизации.

Приложение будет взято из текущей папки, должно определиться как Sinatra. 
Внешние сервисы не используем. Если всё ок - то должно стратовать.

Если ошибка, то получение логов командой:

    vmc logs vk-test

Где `vk-test` - название приложения.

После модификаций файлов, повторное размещение уже для созданного приложения,
выполняется по команде `update`:

    vmc update vk-test

Должны обновиться файлы либо добавиться новые, остановка приложения и запуск.

Если всё успешно, то набрав в браузере `http://vk-test.cloudfoundry.com`
вы должны увидеть ссылку для авторизации, после авторизации - список тестовых
API команд.



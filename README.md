# Ambiente de desenvolvimento para Landing Page Originals

## O que será necessário para desenvolver:

* **Docker Desktop** - para rodar o container com todas as ferramentas.
* **VueJS - framework** JavaScript para o Front End da aplicação.
* **Laravel Lumen** -  Como API da aplicação.
* **MariaDB** - como banco de dados da aplicação.

## Como criar esse ambiente:

Criar os seguintes arquivos ->

Antes de tudo, crie uma pasta principal com o nome do projeto no Disco Local;

* pasta src (A qual terá as pastas do VueJS e Laravel Lumen)
* dockerfile (com os atributos da imagem)
* docker-compose.yml (configurações do container)
* .env (configurações do banco de dados)

## Feito isso os seguintes comandos devem ser realizados:

### Instalando o Vuejs de forma local:

##### Primeiramente instalar o Nodejs na máquina de acordo com o link: 

https://nodejs.org/en/download/

Para isso, faça o teste na linha de comando:

`node -v`

E a mensagem que deve ser exibida é algo como:

        v16.15.1

Feito isso, sua máquina estará apta para instalar o Vue CLI para que os seguintes comandos sejam possíveis.

Execute o comando:

`npm install -g @vue/cli`

ou

`yarn global add @vue/cli`

Para se certificar, faça o teste na linha de comando:

`vue --version`

E a mensagem que deve ser exibida é algo como:

        @vue/cli 5.0.8

Bom, já com o Vuejs instalado em sua máquina, está apto para instalar as ferramentas do framework em seu projeto.

Dentro da pasta src (com o comando cd src) execute na linha de comando ->

`vue create client`

E configure o VueJS com essas features usando as setas, espaço e enter do teclado.:

[x] Manually select features

[x] Babel, Linter/formatter, CSS Pre-processors

[x] 3.x

[x] Sass/SCSS

[x] ESLint + Standard config

[x] Lint on save

[x] In dedicated config files

### Criando e subindo o container Docker

Já com os arquivos .env, docker-compose.yml e dockerfile configurados;

.env ->

        DB_CLIENT=mysql
        DB_PORT=3306
        DB_DATABASE=banco_de_dados
        DB_USER="root"
        DB_PASSWORD=root

docker-compose.yml ->

        version: '3.7'
        services:
        # Imagem MariaDB para banco de dados
                database:
                        container_name: db-server
                        image: mariadb
                        environment:
                                MARIADB_ROOT_PASSWORD: ${DB_PASSWORD}
                                MARIADB_DATABASE: ${DB_DATABASE}
                                MARIADB_USER: ${DB_USER}
                                MARIADB_PASSWORD: ${DB_PASSWORD}
                        volumes:
                        - "./var/lib/mysql"
                        ports:
                        - 3306:3306
                        networks:
                        - project
        # Imagem PHP setada para Laravel
                api:
                        container_name: api-server
                        build:
                                dockerfile: Dockerfile
                                context: ./
                        volumes:
                        - "./src:/var/www/html"
                        ports:
                        - 8000:80
                        networks:
                        - project
                        depends_on:
                        - database
        # Declaração de rede 
        networks:
        project:
        name: "banco_de_dados"

Dockerfile ->

        FROM php:8.1.7-apache
        
        # Instalar as extensões do PHP necessárias para o funcionamento do Laravel Lumen
        
        RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        && docker-php-ext-configure gd --with-freetype --with-jpeg \
        && docker-php-ext-install -j$(nproc) gd
        RUN docker-php-ext-install bcmath
        RUN docker-php-ext-install pdo pdo_mysql mysqli
        
        # Instalar o Composer (PHP Composer)
        
        COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
        
        # Instalar o Git
        
        RUN apt-get install -y zip git
        
        # Configurações do Apache
        
        ENV APACHE_DOCUMENT_ROOT=/var/www/html/api/public
        RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
        RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
        RUN a2enmod rewrite
        RUN ps aux | egrep '(apache|httpd)'

Para criar o container exute o comando ->

`docker-compose build`

Se não der nenhum erro de criação, suba o container com o comando ->

`docker-compose up`

#### Feito isso, os containers estarão funcionando, para se certificar olhe no app Docker Desktop na parte de 'containers' devem estar com a mensagem "running" na cor verde.

Ou pelo seguinte comando ->

`docker ps`

#### Agora que os containers foram criados e estão funcionando, para instalar o laravel, será necessário entrar na máquina linux, a qual foi configurada para obter o PHP e Apache já com Composer instalado e o Git.

Para isso, execute o seguinte comando ->

`docker-compose exec name-service bash`

Feito isso estará dentro do seu container linux já com o composer instalado, dito isso, execute o comando de instalação do Laravel Lumen ->

`composer create-project --prefer-dist laravel/lumen api`

O Laravel Lumen será instalado, e para testar, entre na pasta a qual foi instalado execute `cd api`.

E utilize o comando `php artisan` para se certificar que o Laravel está funcionando como deveria.

E a resposta que deve ser retornada é algo como:

        Laravel Framework Lumen (9.0.3) (Laravel Components ^9.0)

### Configurando o banco de dados do Laravel com arquivo .env

Para isso, faça com que o arquivo .env esteja igual aos dados contidos no .env do Laravel(instalado na pasta api).

        DB_CLIENT=mysql
        DB_PORT=3306
        DB_DATABASE=banco_de_dados
        DB_USER="root"
        DB_PASSWORD=root

Pronto, o banco de dados está configurado e para migrar será necessário executar o comando ->

`php artisan migrate:install`

Aparecerá uma mensagem de sucesso e o banco de dados vai estar funcionando e já estará migrado.






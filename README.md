# api.metatooth.com

> A Sinatra.rb project

## Getting Started

### Prerequisites

#### Ubuntu 20.04

```
$ sudo apt-get update
$ sudo apt-get install libpq-dev libxml2-dev postgresql postgresql-server-dev-11 ruby-bundler ruby-dev
```

### get code & install dependencies

``` bash
$ git clone https://github.com/metatooth/api.git
$ cd api
$ bundle install --path vendor/bundle
```

### initialize database & environment variables

``` bash
$ sudo -u postgres psql
postgres=# create database metaspace_development;
CREATE DATABASE
postgres=# create user metaspace with password 'metaspace';
CREATE ROLE
postgres=# grant all privileges on database metaspace_development to metaspace;
GRANT
postgres=# \q
$ echo "DATABASE_URL=postgres://metaspace:metaspace@localhost/metaspace_development" > .env
```

### serve with hot reload at localhost:9393
```
bundle exec foreman run shotgun
```

## License

Copyright 2021 Metatooth LLC. See the [LICENSE](LICENSE).

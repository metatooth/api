# api

> A Sinatra.rb project

## Getting Started

``` bash
# sudo -u postgres psql
postgres=# create user metaspace with password 'metaspace';
CREATE ROLE
postgres=# grant all privileges on database metaspace_development to metaspace;
GRANT
postgres=# \q
# echo "DATABASE_URL=postgres://metaspace:metaspace@localhost/metaspace_development" > .env

# install dependencies
bundle install

# serve with hot reload at localhost:9393
bundle exec foreman run shotgun
```

# README

## Getting started

### Building docker stuff
docker build -t app .

### Run migration
docker-compose run web bin/rails db:migrate RAILS_ENV=development

### Rails console
docker-compose run web bin/rails console -e development

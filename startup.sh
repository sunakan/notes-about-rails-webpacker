#!/bin/bash

bundle check || bundle install -j4 --path vendor/bundle

bundle exec rake db:create
bundle exec rake db:migrate

bundle exec puma -C config/puma.rb

#! /bin/bash

bundle install
rake db:migrate
rake db:migrate RAILS_ENV=test
rake users:create_admin
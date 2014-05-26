#!/bin/bash
cd /rails/asf
source /usr/local/rvm/environments/ruby-1.9.3-p448
rake asf:exec_import_job RAILS_ENV=production --trace


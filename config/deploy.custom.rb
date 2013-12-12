# Copy this file to config/deploy.custom.rb
require "rvm/capistrano"

# Server you will be running kochiku on
set :kochiku_host, "kochiku-server-41925.phx-os1.stratus.dev.ebay.com"
set :user, "stack"
set :ssh_options, { :forward_agent => true }

set :rvm_ruby_string,  "2.0.0-p0"              # use the same ruby as used locally for deployment
set :rvm_autolibs_flag, "read-only"       # more info: rvm help autolibs

before 'deploy:setup', 'rvm:install_rvm'  # install/update RVM
before 'deploy:setup', 'rvm:install_ruby' # install Ruby and create gemset, OR:
# before 'deploy:setup', 'rvm:create_gemset' # only create gemset
# Add any other capistrano configuration that you like here

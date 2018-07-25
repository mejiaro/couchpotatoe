# config valid only for Capistrano 3.1
lock '3.2.1'
app_name = Rails.application.secrets.deploy_app_name
set :application, app_name
set :repo_url, Rails.application.secrets.deploy_repo_url

set :rvm_type, :user
set :rvm_ruby_version, '2.0.0-p353' # Or whatever env you want it to run in.

set :sidekiq_queue, %w(default mailers)
set :sidekiq_concurrency, 1
set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set :deploy_to, "/var/www/rails/#{app_name}"

#ssh_options[:forward_agent] = true

set :user, Rails.application.secrets.deploy_user
set :password, Rails.application.secrets.deploy_password

set :ssh_options, {
    forward_agent: true,
    port: 22,
    auth_methods: %w(password),
    password: Rails.application.secrets.deploy_password
}

set :use_sudo, false


require 'capistrano-db-tasks'
set :disallow_pushing, true
set :db_local_clean, true

set :branch, "master"

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
# set :deploy_to, '/var/www/my_app'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml}

set :linked_dirs, %w{assets log tmp/pids tmp/cache tmp/sockets}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do
  desc 'Make bins executable'
  task :make_bins_executable do
    on roles(:app) do
      %w{rails rake bundle}.each do |rails_executable|
       execute "chmod +x #{release_path.join("bin/#{rails_executable}")}"
      end
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :make_bins_executable
  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end

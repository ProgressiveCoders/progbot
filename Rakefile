# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

namespace :progbot do
  desc "Update users from AirTable"
  task :import_users do
    system "./bin/import_users"
  end
end

require 'fileutils'

namespace :maintenance do
  task :defaults do
    set :maintenance_app_path, fetch(:app_path, "web")
    set :maintenance_template_path, 'templates'
    set :maintenance_basename, 'maintenance.html'
  end

  desc "Check required files and directories exist"
  task :check do
    on release_roles :all do
      unless test "[ -d #{current_path}/#{fetch(:maintenance_app_path)} ]"
          msg = "Configured Maintenance App Path : #{current_path}/#{fetch(:maintenance_app_path)} is not a directory."
          error msg
          fail Capistrano::FileNotFound, msg
      end

      unless test "[ -e #{fetch(:deploy_to)}/#{fetch(:maintenance_template_path)}/#{fetch(:maintenance_basename)} ]"
          msg = "Configured Maintenance file: #{fetch(:deploy_to)}/#{fetch(:maintenance_template_path)}/#{fetch(:maintenance_basename)} is not a file."
          error msg
          fail Capistrano::FileNotFound, msg
      end
    end
  end

  desc "Enable the maintenance mode"
  task :on do
    on roles(:web) do
      src = fetch(:deploy_to) + '/' + fetch(:maintenance_template_path) +'/'+ fetch(:maintenance_basename)
      dest = release_path.join(fetch(:maintenance_app_path)).join(fetch(:maintenance_basename))
      execute :cp, "#{src}", "#{dest}"
    end
  end

  desc "Disable the maintenance mode"
  task :off do
    on roles(:web) do
      dest = release_path.join(fetch(:maintenance_app_path)).join(fetch(:maintenance_basename))
      execute :rm, "#{dest}"
    end
  end
end

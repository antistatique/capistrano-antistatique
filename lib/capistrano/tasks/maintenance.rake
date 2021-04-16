require 'fileutils'

namespace :load do
  task :defaults do
    set :maintenance_app_path, fetch(:app_path, 'public')
    set :maintenance_template_path, -> { shared_path }
    set :maintenance_basename, 'maintenance.html'
  end
end

namespace :maintenance do
  desc "Check required files and directories exist"
  task :check do
    on roles(:web) :all do
      unless test "[ -d #{current_path}/#{fetch(:maintenance_app_path)} ]"
          msg = "Configured Maintenance App Path : #{current_path}/#{fetch(:maintenance_app_path)} is not a directory."
          error msg
          fail Capistrano::FileNotFound, msg
      end

      unless test "[ -f #{fetch(:maintenance_template_path)}/#{fetch(:maintenance_basename)} ]"
          msg = "Configured Maintenance file: #{fetch(:maintenance_template_path)}/#{fetch(:maintenance_basename)} is not a file."
          error msg
          fail Capistrano::FileNotFound, msg
      end
    end
  end

  desc "Enable the maintenance mode"
  task :on do
    on roles(:web) do
      src = "#{fetch(:maintenance_template_path)}/#{fetch(:maintenance_basename)}"
      dest = current_path.join(fetch(:maintenance_app_path), fetch(:maintenance_basename))
      execute :cp, src, dest
    end
  end

  desc "Disable the maintenance mode"
  task :off do
    on roles(:web) do
      dest = current_path.join(fetch(:maintenance_app_path), fetch(:maintenance_basename))
      execute :rm, dest
    end
  end
end

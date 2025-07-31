namespace :wordpress do
 
  desc "Install WP cli"
  task :install_executable do
    on roles(:web) do
      within shared_path do
        execute 'curl --silent -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar'
        execute 'chmod +x wp-cli.phar'
      end
    end
  end

  desc 'Run any wpcli command'
  task :cli do
    ask(:wp_command, "wpcli command you want to run (eg. 'plugin activate --all'). Type 'help' to have a list of avaible commands.")
    on roles(:app) do
      within release_path do
        execute :wp, fetch(:wp_command)
      end
    end
  end

  namespace :plugin do
    desc "Activates all WordPress plugins."
    task :activate do
      on roles(:web) do
        within release_path do
          execute :wp, 'plugin activate --all'
        end
      end
    end
  end

  namespace :plugins do
    namespace :blocks do
      desc "Build plugins blocks locally"
      task :build do
        on roles(:app) do
          run_locally do
            file_paths = ENV['CHANGED_PATHS'].nil? ? [] : ENV['CHANGED_PATHS'].split(' ')
            custom_plugins_path = fetch(:custom_plugins_path, 'web/app/custom-plugins').gsub(%r{^/|/$}, '')

            find_plugins_directories(custom_plugins_path, file_paths).each do |dir|
              info "Build plugin at #{dir}"
              execute "cd #{dir} && bun install --silent && bun run build"
            end
          end
        end
      end
    end
  end

  namespace :database do
    desc "Download database locally with datetime in filename"
    task :download_locally do
      on roles(:db) do |host|
        datetime = Time.now.strftime("%Y%m%d_%H%M%S")
        remote_sql_file = "#{fetch(:tmp_dir)}/wordpress_#{datetime}.sql.gz"
        local_sql_file = "dump/#{fetch(:stage)}_wordpress_#{host.hostname}_#{datetime}.sql.gz"

        # Prepare the destination dump dir.
        run_locally do
          execute "mkdir -p dump"
        end

        # run the SQL database export with wp-cli
        within release_path do
          execute :wp, "db export - | gzip > #{remote_sql_file}"
        end

        download! remote_sql_file, local_sql_file

        # Cleanup.
        execute "rm #{remote_sql_file}"

        info ""
        info "\e[32mDatabase downloaded locally in #{local_sql_file}\e[0m"
        info "Execute the following command to import the database in the Docker dev environment:"
        info ""
        info "\e[33m  docker compose exec dev wp db create\e[0m"
        info "\e[33m  gunzip -c #{local_sql_file} | docker compose exec -T dev wp db import -\e[0m"
        info ""
      end
    end
  end

  namespace :files do
    desc "Download WordPress uploads files (from remote to local)"
    task :download do
      run_locally do
        on release_roles :app do |server|
          ask(:answer, "Do you really want to download uploads files from the remote server to your local machine? Nothings will be deleted but files can be ovewrite. (y/N)");
          if fetch(:answer) == 'y' then
            remote_files_dir = "#{shared_path}/#{(fetch(:app_path))}/app/uploads/"
            local_files_dir = "#{(fetch(:app_path))}/app/uploads/"
            system("rsync --recursive --times --rsh=ssh --human-readable --progress #{server.user}@#{server.hostname}:#{remote_files_dir} #{local_files_dir}")
          end
        end
      end
    end
  end
end

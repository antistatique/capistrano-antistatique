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
end

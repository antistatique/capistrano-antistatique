namespace :wordpress do
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

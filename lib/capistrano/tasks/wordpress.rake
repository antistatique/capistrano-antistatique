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
end

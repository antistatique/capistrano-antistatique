namespace :cachetool do
  namespace :opcache do
    task :reset do
      on release_roles(fetch(:cachetool_roles)) do
        within fetch(:cachetool_working_dir) do
          execute :cachetool, "opcache:reset --web --web-path=#{release_path}/web --web-url=#{fetch(:cachetool_reset_web_url)}", raise_on_non_zero_exit: false
        end
      end
    end
  end
end
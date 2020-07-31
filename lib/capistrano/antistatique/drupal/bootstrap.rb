namespace :deploy do
  desc 'Bootstrap Drupal site with drush site-install command'
  task :bootstrap do
    warn <<-EOF

    ************************** WARNING ****************************
    If you type [yes], cap drupal:bootstrap will WIPE your database
    any other input will cancel the operation.
    ***************************************************************

    EOF
    ask :answer, 'Are you sure you want to WIPE your database? ([no]/yes)'
    if fetch(:answer) != 'yes'
      warn 'Abort bootstrap!'
      exit 1
    end

    after 'composer:install', :bootstrap do
      default = YAML.load_file("#{fetch(:config_path)}/system.site.yml")

      ask(:drupal_uuid, default['uuid'])
      ask(:drupal_site_name, default['name'])
      ask(:drupal_admin_username, 'admin')
      ask(:drupal_admin_passowrd, 'admin', echo: false)
      ask(:drupal_admin_email, default['mail'])
      ask(:site_name, "Site name")

      on roles(:app) do
        if File.exists?(current_path) && !File.symlink?(current_path)
          info "Recursively delete the current directory #{current_path} to prevent fail on symlink creation."
          execute :rm, '-rf', current_path
        end

        within release_path.join(fetch(:app_path)) do
          execute :drush, 'si standard -y',
            %(--site-name="#{fetch(:drupal_site_name)}"),
            %(--account-name="#{fetch(:drupal_admin_username)}"),
            %(--account-pass="#{fetch(:drupal_admin_passowrd)}"),
            %(--account-mail="#{fetch(:drupal_admin_email)}")

          info 'Fix Drupal installation'
          execute :drush, %(config-set system.site uuid "#{fetch(:drupal_uuid)}" -y)
          execute :drush, %(ev '\Drupal::entityTypeManager()->getStorage("shortcut_set")->load("default")->delete();')
          execute :drush, %(ev '
            $user = user_load_by_name("#{fetch(:drupal_admin_username)}");
            $user->set("preferred_admin_langcode", "en");
            $user->save();
          ')
        end
      end
    end

    invoke 'deploy'
  end
end

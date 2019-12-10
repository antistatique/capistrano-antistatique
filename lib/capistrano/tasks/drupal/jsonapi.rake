##
# JSON:API Recipes
#
# Manage your Drupal Json API.
# @see https://www.drupal.org/docs/8/core/modules/jsonapi-module
##

namespace 'drupal:jsonapi' do
  namespace :explorer do

    desc "Enable JSON:API Explorer"
    task :enable do
      on roles(:app) do
        within release_path.join(fetch(:app_path)) do
          execute :drush, "en", "jsonapi_explorer", "-y"
        end
      end
    end

    desc "Disable JSON:API Explorer"
    task :disable do
      on roles(:app) do
        within release_path.join(fetch(:app_path)) do
          execute :drush, "pmu", "jsonapi_explorer", "-y"
        end
      end
    end
  end

end
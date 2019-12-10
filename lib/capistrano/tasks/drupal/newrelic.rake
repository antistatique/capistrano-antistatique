##
# New Relic Recipes
#
# Manage your Drupal New Relic module.
# @see https://www.drupal.org/project/new_relic_rpm
##

namespace 'drupal:newrelic' do
  desc "Mark a deployment in New Relic using the current revision ID."
  task :deploy do
    on roles(:app) do
      within release_path.join(fetch(:app_path)) do
        set :current_revision, `git rev-list --max-count=1 #{fetch(:branch)}`.strip
        execute :drush, "new-relic-rpm:deploy", fetch(:current_revision)
      end
    end
  end
end
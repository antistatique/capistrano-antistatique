##
# Elasticsearch Helper Recipe
#
# helper module to work with Elasticsearch on Drupal project.
# @see https://www.drupal.org/project/elasticsearch_helper
##
namespace 'drupal:elasticsearch' do
  desc 'Clears all search indexes and marks them for reindexing.'
  task :clear do
    on roles(:app) do
      within release_path.join(fetch(:app_path)) do
        execute :drush, 'eshd', '-y'
        execute :drush, 'eshs'
        execute :drush, 'eshr'
      end
    end
  end

  desc 'Indexes items for one or all enabled search indexes.'
  task :index do
    on roles(:app) do
      within release_path.join(fetch(:app_path)) do
        execute :drush, 'queue-run', 'elasticsearch_helper_indexing'
      end
    end
  end
end

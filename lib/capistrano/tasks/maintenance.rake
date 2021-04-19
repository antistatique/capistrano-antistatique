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
    on roles(:web) do
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

  desc "Initialize maintenance requirements"
  task :install do
    on roles(:web) do
      template_dir = "#{fetch(:maintenance_template_path)}"
      unless test "[ -d #{template_dir} ]"
          execute :mkdir, "-p", "#{fetch(:maintenance_template_path)}"
      end

      template_file = "#{fetch(:maintenance_template_path)}/#{fetch(:maintenance_basename)}"
      unless test "[ -f #{template_file} ]"
          [
            '<!doctype html>',
            '<title>Site Maintenance</title>',
            '<style>',
              'body { text-align: center; padding: 150px; }',
              'h1 { font-size: 50px; }',
              'body { font: 20px Helvetica, sans-serif; color: #333; }',
              'article { display: block; text-align: left; width: 650px; margin: 0 auto; }',
              'a { color: #dc8100; text-decoration: none; }',
              'a:hover { color: #333; text-decoration: none; }',
            '</style>',
            '<article>',
                '<h1>We&rsquo;ll be back soon!</h1>',
                '<div>',
                    '<p>Sorry for the inconvenience but we&rsquo;re performing some maintenance at the moment. We&rsquo;ll be back online shortly!</p>',
                '</div>',
            '</article>'
          ].each { |line| execute "echo '#{line}' >> #{template_file}" }
      end

      info ""
      info "Add the \e[35mfollowing configuration\e[0m to your Apache \e[35m.htaccess\e[0m file:"
      info "=============================="
      info "<LocationMatch \"\\.(css|gif|ico|jpe?g|js|png|svg|webp|webm)$\">"
      info "    ErrorDocument 503 \"Service unavailable.\""
      info "</LocationMatch>"
      info "<IfModule mod_rewrite.c>"
      info "    <If \"! %{REQUEST_URI} =~ /\\.(css|gif|ico|jpe?g|js|png|svg|webp|webm)$/i && -f '%{DOCUMENT_ROOT}/#{fetch(:maintenance_basename)}'\">"
      info "        ErrorDocument 503 /#{fetch(:maintenance_basename)}"
      info "    </If>"
      info "    RewriteEngine On"
      info "    RewriteCond \"%{ENV:REDIRECT_STATUS}\" !=503"
      info "    RewriteCond %{DOCUMENT_ROOT}/#{fetch(:maintenance_basename)} -f"
      info "    RewriteCond %{SCRIPT_FILENAME} !#{fetch(:maintenance_basename)}"
      info "    RewriteRule \".*\" \"-\" [R=503,L,E=NOCACHE:1]"
      info "    Header always set Cache-Control \"no-store, no-cache, must-revalidate\" env=REDIRECT_NOCACHE"
      info "</IfModule>"
      info "=============================="
    end
  end
end

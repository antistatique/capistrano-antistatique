require 'set'

load File.expand_path('../../tasks/wordpress.rake', __FILE__)

def find_plugins_directories(custom_plugins_path, file_paths)
  if file_paths.empty?
    file_paths = Dir.glob(["#{custom_plugins_path}/*/package.json", "#{custom_plugins_path}/*/*/package.json"])
  end

  plugin_dirs = Set.new
  file_paths.each do |filepath|
    next if filepath.empty?

    if filepath =~ %r{^(?:\./)?#{custom_plugins_path}/([^/]+)}
      plugin_name = $1
      plugin_path = "#{custom_plugins_path}/#{plugin_name}"

      if !File.exist?("#{plugin_path}/package.json")
        plugin_path = find_plugins_directories(plugin_path, [filepath]).first
      end

      plugin_dirs.add(plugin_path) if plugin_path && File.exist?("#{plugin_path}/package.json")
    end
  end

  plugin_dirs.to_a.sort
end
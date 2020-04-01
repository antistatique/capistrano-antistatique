# Capistrano::Antistatique

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/capistrano/antistatique`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'capistrano-antistatique'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capistrano-antistatique

Then you will need to install some extra dependency according your platform

    - Drupal

    ```ruby
    gem 'capdrupal'
    ```

    - Symfony

    ```ruby
    gem 'capistrano/symfony'
    ```

## Configuration

First, go to your project directory and launch Capistrano.

```shell
cd path/to/your/drupal/project/
cap install
```

Capistrano will create the following skeleton

```
.
├── Capfile
├── config
│   └── deploy.rb
│   └── deploy
│       └── production.rb
│       └── staging.rb
├── lib
│   └── capistrano
│        └── tasks

```

Create two files `Capfile` and `config/deploy.rb`. Open `Capfile` and set the depencies.

```ruby
# Load DSL and set up stages.
require 'capistrano/setup'

# Include default deployment tasks.
require 'capistrano/deploy'

# Composer is needed to install drush on the server.
require 'capistrano/composer'

# Antistatique Tasks.
require 'capistrano/antistatique'

# Drupal Tasks.
require 'capdrupal'

# Drupal-Antistatique specific Tasks.
# Always load Drupal add-on after capdrupal.
require 'capistrano/antistatique/drupal/loco'
require 'capistrano/antistatique/drupal/sapi'
require 'capistrano/antistatique/drupal/newrelic'
require 'capistrano/antistatique/drupal/elasticsearch'

# Load custom tasks from `lib/capistrano/tasks` if you have any defined.
Dir.glob('config/capistrano/tasks/*.rake').each { |r| import r }
```

Then, go to `config/deploy.rb`, `config/deploy/staging.rb`, `conconfig/deploy/production.rb` to set the parameters of your project.

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/antistatique/capistrano-antistatique.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

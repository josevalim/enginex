require "thor/group"
require "active_support"
require "active_support/version"
require "active_support/core_ext/string"

require "rails/generators"
require "generators/rails/app/app_generator"

class Enginex < Thor::Group
  VERSION = "0.3.0".freeze

  include Thor::Actions
  check_unknown_options!

  def self.source_root
    @_source_root ||= File.expand_path('../templates', __FILE__)
  end

  def self.say_step(message)
    @step = (@step || 0) + 1
    class_eval <<-METHOD, __FILE__, __LINE__ + 1
      def step_#{@step}
        #{"puts" if @step > 1}
        say_status "STEP #{@step}", #{message.inspect}
      end
    METHOD
  end

  argument :path, :type => :string,
                  :desc => "Path to the engine to be created"

  class_option :test_framework, :default => :test_unit
  
  desc "Creates a Rails 3 engine with Rakefile, Gemfile and running tests."

  say_step "Creating gem skeleton"

  def create_root
    self.destination_root = File.expand_path(path, destination_root)
    set_accessors!

    directory "root", "."
    FileUtils.cd(destination_root)
    
    inside path do
      remove_file "spec" if test_unit?
      remove_file "test" if rspec?
    end
  end

  def copy_gitignore
    copy_file "gitignore", ".gitignore"
  end

  say_step "Vendoring Rails application at test/dummy"

  def invoke_rails_app_generator
    invoke Rails::Generators::AppGenerator,
      [ File.expand_path(dummy_path, destination_root) ]
  end

  say_step "Configuring Rails application"

  def change_config_files
    store_application_definition!
    template "rails/boot.rb", "#{dummy_path}/config/boot.rb", :force => true
    template "rails/application.rb", "#{dummy_path}/config/application.rb", :force => true
    gsub_file "#{dummy_path}/config/environments/test.rb", "end\n", <<-CONTENT

  # Remove show exceptions middleware from tests, so we always Ruby failures.
  config.middleware.delete "ActionDispatch::ShowExceptions"
end
    CONTENT
  end

  say_step "Removing unneeded files"

  def remove_uneeded_rails_files
    inside dummy_path do
      remove_file ".gitignore"
      remove_file "db/seeds.rb"
      remove_file "doc"
      remove_file "Gemfile"
      remove_file "lib/tasks"
      remove_file "public/images/rails.png"
      remove_file "public/index.html"
      remove_file "public/robots.txt"
      remove_file "Rakefile"
      remove_file "README"
      remove_file "test"
      remove_file "vendor"
    end
  end

  protected

    def rspec?
      options[:test_framework] == "rspec"
    end

    def test_unit?
      options[:test_framework] == "test_unit"
    end
    
    def dummy_path
      rspec? ? 'spec/dummy' : 'test/dummy'
    end

    def self.banner
      self_task.formatted_usage(self, false)
    end

    def application_definition
      @application_definition ||= begin
        contents = File.read(File.expand_path("#{dummy_path}/config/application.rb", destination_root))
        contents[(contents.index("module Dummy"))..-1]
      end
    end
    alias :store_application_definition! :application_definition

    # Cache accessors since we are changing the directory
    def set_accessors!
      self.name
      self.class.source_root
    end

    def name
      @name ||= File.basename(destination_root)
    end

    def camelized
      @camelized ||= name.camelize
    end

    def underscored
      @underscored ||= name.underscore
    end
end

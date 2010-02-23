require "thor/group"
require "active_support"
require "active_support/version"
require "active_support/core_ext/string"

require "rails/generators"
require "generators/rails/app/app_generator"

class Enginex < Thor::Group
  VERSION = "0.1.0".freeze

  include Thor::Actions
  check_unknown_options!

  def self.source_root
    @_source_root ||= File.expand_path('../templates', __FILE__)
  end

  argument :path, :type => :string,
                  :desc => "Path to the engine to be created"

  class_option :help, :type => :boolean, :aliases => "-h",
                      :desc => "Show this help message and quit"

  def step_1
    say_status "STEP 1", "Creating engine skeleton"
  end

  def create_root
    self.destination_root = File.expand_path(path, destination_root)
    set_accessors!

    directory "root", "."
    FileUtils.cd(destination_root)
  end

  def copy_gitignore
    copy_file "gitignore", ".gitignore"
  end

  def step_2
    puts
    say_status "STEP 2", "Vendoring Rails application at test/dummy"
  end

  def invoke_rails_app_generator
    invoke Rails::Generators::AppGenerator,
      [ File.expand_path("test/dummy", destination_root) ]
  end

  def step_3
    puts
    say_status "STEP 3", "Configuring Rails application"
  end

  def change_config_files
    store_application_definition!
    template "rails/boot.rb", "test/dummy/config/boot.rb", :force => true
    template "rails/application.rb", "test/dummy/config/application.rb", :force => true
  end

  def step_4
    puts
    say_status "STEP 4", "Removing uneeded files"
  end

  def remove_uneeded_rails_files
    inside "test/dummy" do
      remove_file "config.ru"
      remove_file "db/seeds.rb"
      remove_file "doc"
      remove_file "Gemfile"
      remove_file "Rakefile"
      remove_file "README"
      remove_file "test"
      remove_file "vendor"
    end
  end

  protected

    def application_definition
      @application_definition ||= begin
        contents = File.read(File.expand_path("test/dummy/config/application.rb", destination_root))
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
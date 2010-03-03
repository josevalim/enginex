require "thor/group"
require "active_support"
require "active_support/version"
require "active_support/core_ext/string"

require "rails/generators"
require "generators/rails/app/app_generator"

# TODO Remove webrat hack file
class Enginex < Thor::Group
  VERSION = "0.2.0".freeze

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

  desc "Creates a Rails 3 engine with Rakefile, Gemfile and running tests."

  say_step "Creating gem skeleton"

  def create_root
    self.destination_root = File.expand_path(path, destination_root)
    set_accessors!

    directory "root", "."
    FileUtils.cd(destination_root)
  end

  def copy_gitignore
    copy_file "gitignore", ".gitignore"
  end

  say_step "Vendoring Rails application at test/dummy"

  def invoke_rails_app_generator
    invoke Rails::Generators::AppGenerator,
      [ File.expand_path("test/dummy", destination_root) ]
  end

  say_step "Configuring Rails application"

  def change_config_files
    store_application_definition!
    template "rails/boot.rb", "test/dummy/config/boot.rb", :force => true
    template "rails/application.rb", "test/dummy/config/application.rb", :force => true
  end

  say_step "Removing unneeded files"

  def remove_uneeded_rails_files
    inside "test/dummy" do
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

    def self.banner
      self_task.formatted_usage(self, false)
    end

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

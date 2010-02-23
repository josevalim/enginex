require "thor/group"
require "active_support"
require "active_support/core_ext/string"

class Enginex < Thor::Group
  VERSION = "0.1.0".freeze

  include Thor::Actions
  check_unknown_options!

  def self.source_root
    @_source_root ||= File.expand_path('../templates', __FILE__)
  end

  argument :path, :type => :string,
                  :desc => "Path to the engine to be created"

  class_option :bare, :type => :boolean, :default => false,
                      :desc => "Skip vendored Rails application for testing"

  class_option :help, :type => :boolean, :aliases => "-h",
                      :desc => "Show this help message and quit"

  def create_root
    self.destination_root = File.expand_path(path, destination_root)
    set_name!

    empty_directory "."
    FileUtils.cd(destination_root)
  end

  def copy_root_files
    directory "root", "."
  end

  

  protected

    def name
      @name ||= File.basename(destination_root)
    end
    alias :set_name! :name

    def camelized
      @camelized ||= name.camelize
    end

    def underscored
      @underscored ||= name.underscore
    end
end
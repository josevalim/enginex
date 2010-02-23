require "thor/group"
require "active_support"
require "active_support/core_ext/string"

class Enginex < Thor::Group
  include Thor::Actions
  check_unknown_options!

  argument :path, :type => :string,
                  :desc => "Path to the engine to be created"

  class_option :bare, :type => :boolean, :default => false,
                      :desc => "Skip vendored Rails application for testing"

  def create_root
    self.destination_root = File.expand_path(path, destination_root)
    set_name!

    empty_directory "."
    FileUtils.cd(destination_root)
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
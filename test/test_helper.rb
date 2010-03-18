require 'rubygems'

begin
  gem "test-unit"
rescue LoadError
end

ENV["RAILS_ENV"] ||= "test"
require 'fileutils'
require 'test/unit'
require 'active_support'
require 'active_support/test_case'

$counter = 0
LIB_PATH = File.expand_path('../../lib', __FILE__)
BIN_PATH = File.expand_path('../../bin/enginex', __FILE__)

DESTINATION_ROOT = File.expand_path('../enginex', __FILE__)
FileUtils.rm_rf(DESTINATION_ROOT)

$:.unshift LIB_PATH
require 'enginex'

class ActiveSupport::TestCase
  def run_enginex(suite = :test_unit)
    if suite == :rspec
      option = '--test-framework=rspec'
    else
      option = '--test-framework=test_unit'
    end

    $counter += 1
    `ruby -I#{LIB_PATH} -rrubygems #{BIN_PATH} #{destination_root} #{option}`
    yield
    FileUtils.rm_rf(File.dirname(destination_root))
  rescue Exception => e
    puts "Error happened. #{destination_root.inspect} left for inspecting."
    raise e
  end

  def destination_root
    File.join(DESTINATION_ROOT, $counter.to_s, "demo_engine")
  end

  def capture(stream)
    begin
      stream = stream.to_s
      eval "$#{stream} = StringIO.new"
      yield
      eval("$#{stream}").string
    ensure
      eval("$#{stream} = #{stream.upcase}")
    end
  end
  alias :silence :capture

  def assert_file(relative, *contents)
    absolute = File.expand_path(relative, destination_root)
    assert File.exists?(absolute), "Expected file #{relative.inspect} to exist, but does not"

    read = File.read(absolute) if block_given? || !contents.empty?
    yield read if block_given?

    contents.each do |content|
      assert_match content, read
    end
  end
  alias :assert_directory :assert_file

  def assert_no_file(relative)
    absolute = File.expand_path(relative, destination_root)
    assert !File.exists?(absolute), "Expected file #{relative.inspect} to not exist, but does"
  end
  alias :assert_no_directory :assert_no_file

  def execute(command)
    current_path = Dir.pwd
    FileUtils.cd destination_root
    `#{command}`
  ensure
    FileUtils.cd current_path
  end
end
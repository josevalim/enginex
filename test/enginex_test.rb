require 'test_helper'

class EnginexTest < ActiveSupport::TestCase
  test "enginex skeleton" do
    run_enginex do
      # Root
      assert_file "Rakefile"
      assert_file "Gemfile", /gem "rails"/, /gem "webrat"/
      assert_file ".gitignore", /\.bundle/, /db\/\*\.sqlite3/

      # Lib
      assert_file "lib/demo_engine.rb", /module DemoEngine\nend/

      # Test
      assert_file "test/test_helper.rb"
      assert_directory "test/support/"
      assert_directory "test/integration/"

      assert_file "test/demo_engine_test.rb", /assert_kind_of Module, DemoEngine/
      assert_file "test/integration/navigation_test.rb", /assert_kind_of Dummy::Application, Rails.application/

      # Vendored Rails
      assert_file "test/dummy/config/application.rb"
    end
  end

  test "enginex rakefile can create a gem" do
    run_enginex do
      execute("rake gem")
      assert_file "pkg/demo_engine-0.0.1.gem"
    end
  end

  test "enginex can run tests" do
    run_enginex do
      assert_match /2 tests, 2 assertions, 0 failures, 0 errors/, execute("rake test")
    end
  end
end
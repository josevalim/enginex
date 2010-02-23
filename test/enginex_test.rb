require 'test_helper'

class EnginexTest < ActiveSupport::TestCase
  test "it creates root files" do
    run_enginex do
      assert_file "Rakefile"
    end
  end
end
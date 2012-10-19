require 'test/unit'
require 'rbatch'

class RuncherTest < Test::Unit::TestCase
  def setup
    @config_dir =  File.join(File.dirname(RBatch.program_name), "..", "config")
    @config_file = File.join(@config_dir , "test_auto_config.yaml")
    Dir::mkdir(@config_dir) if ! Dir.exists? @config_dir
  end

  def teardown
    File.delete @config_file if File.exist? @config_file
  end

  def test_require
  end

  def test_read_config
    open( @config_file  , "w" ){|f| f.write("key: value")}
    assert_equal "value",  RBatch.read_config["key"]
  end

  def test_read_error
    assert_raise(Errno::ENOENT){
      RBatch.read_config
    }
  end

  def test_double_read
    open( @config_file  , "w" ){|f| f.write("key: value")}
    assert_equal "value",  RBatch.read_config["key"]
    assert_equal "value",  RBatch.read_config["key"]
  end
end

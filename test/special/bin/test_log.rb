require 'test/unit'
require 'fileutils'
require 'rbatch'
class LoggerTest < Test::Unit::TestCase
  def setup
    @dir  = File.join(File.dirname(RBatch.program_name), "..", "log")
    @dir2 = File.join(File.dirname(RBatch.program_name), "..", "log2")
    @dir3 = File.join(File.dirname(RBatch.program_name), "..", "log3")

    Dir::mkdir(@dir)if ! Dir.exists? @dir
    Dir::mkdir(@dir2)if ! Dir.exists? @dir2

#    RBatch::Log.verbose = true
  end

  def teardown
    File::delete(RBatch.common_config_path) if File.exists?(RBatch.common_config_path)
    if Dir.exists? @dir
      Dir::foreach(@dir) do |f|
        File::delete(File.join(@dir , f)) if ! (/\.+$/ =~ f)
      end
      Dir::rmdir(@dir)
    end
    if Dir.exists? @dir2
      Dir::foreach(@dir2) do |f|
        File::delete(File.join(@dir2 , f)) if ! (/\.+$/ =~ f)
      end
      Dir::rmdir(@dir2)
    end
  end

  def test_log
    RBatch::Log.new do | log |
      log.info("test_log")
    end
    Dir::foreach(@dir) do |f|
      if ! (/\.+$/ =~ f)
        File::open(File.join(@dir , f)) {|f|
          assert_match /test_log/, f.read
        }
      end
    end
  end

  def test_log_dir_doesnot_exist
    Dir::rmdir(@dir)
    assert_raise(Errno::ENOENT){
      RBatch::Log.new {|log|}
    }
    Dir::mkdir(@dir)
  end

  def test_change_name_by_opt
    RBatch::Log.new({:name => "name1.log" }) do | log |
      log.info("test_change_name_by_opt")
    end
    File::open(File.join(@dir , "name1.log")) {|f|
      assert_match /test_change_name_by_opt/, f.read
    }
  end

  def test_change_name_by_opt2
    RBatch::Log.new({:name => "<prog><date>name.log" }) do | log |
      log.info("test_change_name_by_opt2")
    end
    File::open(File.join(@dir ,  "test_log" + Time.now.strftime("%Y%m%d") + "name.log")) {|f|
      assert_match /test_change_name_by_opt2/, f.read
    }
  end


  def test_change_name_by_config
    confstr = "log_name: name1"
    open( RBatch.common_config_path  , "w" ){|f| f.write(confstr)}
    RBatch::Log.new({:name => "name1.log" }) do | log |
      log.info("test_change_name_by_config")
    end
    File::open(File.join(@dir , "name1.log")) {|f|
      assert_match /test_change_name_by_config/, f.read
    }
  end


  def test_change_log_dir_by_opt
    RBatch::Log.new({:output_dir=> @dir2 }) do | log |
      log.info("test_change_log_dir_by_opt")
    end
    Dir::foreach(@dir2) do |f|
      if ! (/\.+$/ =~ f)
        File::open(File.join(@dir2 , f)) {|f|
          assert_match /test_change_log_dir_by_opt/, f.read
        }
      end
    end
  end

  def test_change_log_dir_by_config
    confstr = "log_dir: " + @dir2
    open( RBatch.common_config_path  , "w" ){|f| f.write(confstr)}
    RBatch::Log.new({:output_dir=> @dir2 }) do | log |
      log.info("test_change_log_dir_by_config")
    end
    Dir::foreach(@dir2) do |f|
      if ! (/\.+$/ =~ f)
        File::open(File.join(@dir2 , f)) {|f|
          assert_match /test_change_log_dir_by_config/, f.read
        }
      end
    end
  end

  def test_change_formatte
    RBatch::Log.new({:name => "file" , :formatter => proc { |severity, datetime, progname, msg| "test_change_formatte#{msg}\n" }}) do | log |
      log.info("bar")
    end
    File::open(File.join(@dir,"file")) {|f| assert_match /test_change_formatte/, f.read }
  end

  def test_nest_block
    RBatch::Log.new({:name => "name1" }) do | log |
      log.info("name1")
      RBatch::Log.new({:name => "name2" }) do | log |
        log.info("name2")
      end
    end
    File::open(File.join(@dir,"name1")) {|f| assert_match /name1/, f.read }
    File::open(File.join(@dir,"name2")) {|f| assert_match /name2/, f.read }
  end

  def test_opt_overwite_config
    confstr = "log_name: " + "name1"
    open( RBatch.common_config_path  , "w" ){|f| f.write(confstr)}
    RBatch::Log.new({:name => "name2" }) do | log |
      log.info("test_opt_overwite_config")
    end
    File::open(File.join(@dir , "name2")) {|f|
      assert_match /test_opt_overwite_config/, f.read
    }
  end
end

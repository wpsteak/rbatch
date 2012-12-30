$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

module RBatch
  @@program_name = $PROGRAM_NAME
  module_function
  def program_name=(f) ; @@program_name = f ; end
  def program_name ; @@program_name ; end
  def tmp_dir
    case RUBY_PLATFORM
    when /mswin|mingw/
      return ENV["TEMP"]
    when /cygwin|linux/
      return "/tmp/"
    else
      raise "Unknown RUBY_PRATFORM : " + RUBY_PLATFORM
    end
  end
  def common_config_path
    File.join(File.dirname(RBatch.program_name),"..","config","rbatch.yaml")
  end
  def common_config
    if File.exist?(RBatch.common_config_path)
      return YAML::load_file(RBatch.common_config_path)
    else
      return nil
    end
  end
end

require 'rbatch/log'
require 'rbatch/config'
require 'rbatch/cmd'

# double run check
if ( RBatch::common_config != nil && RBatch::common_config["forbid_double_run"] )
  if Dir.exists? RBatch::tmp_dir
    Dir::foreach(RBatch::tmp_dir) do |f|
      if (/rbatch_lock/ =~ f)
        raise "Can not start RBatch. RBatch lock file exists (#{RBatch::tmp_dir}#{f})."
      end
    end
  end
  # make lockfile
  Tempfile::new("rbatch_lock",RBatch::tmp_dir)
end

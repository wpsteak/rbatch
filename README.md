RBatch:Ruby-base Batch Script Framework
=============

About RBatch
--------------
This is a Ruby-base Batch Script Framework.

There are following functions. 

* Auto Logging
* Auto Config Reading
* External Command Wrapper 
* Directory Structure convention

### Auto Logging
Use Auto Logging block, RBatch automatically write to logfile.
Log file default location is "../log/YYYYMMDD_HHMMSS_${PROG_NAME}.log" .
If exception occuerd, then RBatch write stack trace to logfile.

sample

script : ./bin/sample1.rb
```
require 'rbatch'

RBatch::Log.new(){ |log|  # Logging block
  log.info "info string"
  log.error "error string"
  raise "exception"
}
```

logfile : ./log/20121020_005953_sample1.log
```
# Logfile created on 2012-10-20 00:59:53 +0900 by logger.rb/25413
I, [2012-10-20T00:59:53.895528 #3208]  INFO -- : info string
E, [2012-10-20T00:59:53.895582 #3208] ERROR -- : error string
F, [2012-10-20T00:59:53.895629 #3208] FATAL -- : Caught exception; existing 1
F, [2012-10-20T00:59:53.895667 #3208] FATAL -- : exception (RuntimeError)
test.rb:6:in `block in <main>'
/usr/local/lib/ruby192/lib/ruby/gems/1.9.1/gems/rbatch-1.0.0/lib/rbatch/auto_logger.rb:37:in `initialize'
test.rb:3:in `new'
test.rb:3:in `<main>'
```

### Auto Config Reading

RBatch easy to read config file (located on "../config/${PROG_NAME}.yaml")

sample

config : ./config/sample2.yaml
```
key: value
array:
 - item1
 - item2
 - item3
```

script : ./bin/sample2.rb
```
require 'rbatch'
p RBatch::read_config
=> {"key" => "value", "array" => ["item1", "item2", "item3"]}
```

### External Command Wrapper 
RBatch provide a function which wrap external command (such as 'ls').

And, the function return simple hash object which contain command's STDOUT, STDERR ,and exit status.

sample
```
require 'rbatch'
p RBatch::run("ls")
=> {:stdout => "fileA\nfileB\n", :stderr => "", :status => 0}
```

### Directory Structure Convention

RBatch assume following directory structure.

```
./
 |-bin
 |  |- hoge.rb
 |  \- bar.rb
 |-config
 |  |- hoge.yaml
 |  \- bar.yaml
 \-log
    |- YYYYMMDD_HHMMSS_hoge.log
    \- YYYYMMDD_HHMMSS_bar.log
```


Quick Start
--------------
### Step1: Install

```
# git clone git@github.com:fetaro/rbatch.git
# cd rbatch
# rake package
# gem install pkg/rbatch-1.0.0
```

### Step2: Make directories

```
$ mkdir bin log config
```

### Step3: Write batch script with RBatch 

for bin/backup.rb
```
require 'rbatch'

RBatch::Log.new(){|log|
  log.info( "start backup" )
  result = RBatch::run( "cp -p /var/log/message /backup")
  log.info( result )
  log.error ( "backup failed") if result[:status] != 0
}
```

### Step4: Run batch script

```
$ ruby bin/backup.rb
```

### Step5: Check log file

```
$ cat log/YYYYMMDD_HHMMSS_backup.log

# Logfile created on 2012-10-20 00:19:23 +0900 by logger.rb/25413
I, [2012-10-20T00:19:23.422876 #2357]  INFO -- : start backup
I, [2012-10-20T00:19:23.424773 #2357]  INFO -- : {:stdout=>"", :stderr=>"cp: cannot stat `/var/log/message': No such file or directory\n", :status=>1}
E, [2012-10-20T00:19:23.424882 #2357] ERROR -- : backup failed
```
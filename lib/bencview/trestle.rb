# :erb:
require 'yaml'
require 'shellwords.rb'
require 'optparse'
require 'pp'
require 'open4'

require_relative 'meta'

# :include: ../../README.rdoc
module Bencview

  class Trestle

    # Execute _cmd_ and return a list [exit_status, stderr,
    # stdout]. Very handy.
    def self.cmd_run(cmd)
      so = sr = ''
      status = Open4::popen4(cmd) { |pid, stdin, stdout, stderr|
        so = stdout.read
        sr = stderr.read
      }
      [status.exitstatus, sr, so]
    end

    # Return a directory with program libraries.
    def self.gem_libdir
      t = ["#{File.dirname(File.expand_path($0))}/../lib/#{Bencview::Meta::NAME}",
           "#{Gem.dir}/gems/#{Bencview::Meta::NAME}-#{Bencview::Meta::VERSION}/lib/#{Bencview::Meta::NAME}",
           "lib/#{Bencview::Meta::NAME}"]
      t.each {|i| return i if File.readable?(i) }
      fail "all paths are invalid: #{t}"
    end

    # Analogue to shell command +which+.
    def self.in_path?(file)
      return true if file =~ %r%\A/% and File.exist? file

      ENV['PATH'].split(File::PATH_SEPARATOR).any? do |path|
        File.exist? File.join(path, file)
      end
    end

    # Print an error message _t_ and exit if _ec_ > 0.
    def self.errx(ec, t)
      STDERR.puts File.basename($0) + ' error: ' + t.to_s
      exit ec if ec > 0
    end

    # Print a warning.
    def self.warnx(t)
      STDERR.puts File.basename($0) + ' warning: ' + t.to_s
    end

    # #veputs uses this to decide to put a newline or not to put.
    NNL_MARK = '__NNL__'

    # Use this in your CL options to check if modifying some variable is
    # not an idempotent act.
    attr_reader :cl_opt_protect

    # [conf] Typically must be a reference to some global variable.
    def initialize(conf)
      @conf = conf
      @conf[:verbose] = 0
      @conf[:banner] = "Usage: #{File.basename($0)} [options]"
      @conf[:config] =  Meta::NAME + '.yaml'
      @conf[:config_dirs] =  [ENV['HOME']+'/.'+Meta::NAME,
                              File.absolute_path("#{File.dirname(File.expand_path($0))}/../etc"),
                              '/usr/etc', '/usr/local/etc', '/etc',
                              "#{Gem.dir}/gems/#{Meta::NAME}-#{Meta::VERSION}/etc"
                             ]
      @conf[:config_env] = [Meta::NAME.upcase + '_CONF']

      @cl_parsing_times = 0 # not used
      @cl_opt_protect = false
    end

    # [level] A verbose level.
    # [t]     A string to print.
    #
    # Don't print _t_ with a newline if it contains NNL_MARK at the end.
    def veputs(level, t)
      t = t.dup
      nnl = nil
      if t.match(/#{NNL_MARK}$/)
        t.sub!(/#{$&}/, '')
        nnl = 1
      end

      if @conf[:verbose] >= level
        nnl ? print(t) : puts(t)
        STDOUT.flush
      end
    end
    
    # Run all configuration parsing in a batch.
    #
    # [rvars] A list of variable names which must be in the
    #         configuration file.
    #
    # If no block is given, only standard CL options will be analysed.
    def config_parse(rvars, &block)
      cb = ->(b, src) {
        if b
          block.call src
        else
          # very basic default options
          cl_parse(src, nil, true)
        end
      }
      
      # 1. parse env
      @conf[:config_env].each {|i|
#        puts '0 run:'
        cb.call(block_given?, ENV[i].shellsplit) if ENV.key?(i)
      }

      # 2. parse CL in case of '--config' option
#      puts "\n1 run"
      @cl_opt_protect = true
      cb.call(block_given?, ARGV.dup)
      @cl_opt_protect = false

      # 3. load the configuration file & do the final CL parsing
      begin
#        puts "\n2 run"
        r = config_flat_load(rvars)
      rescue
        Trestle.errx(1, "cannot load config: #{$!}")
      end
      veputs(1, "Loaded config: #{r}")
      cb.call(block_given?, ARGV)
    end

    # Load a config file immediately if it contains '/' in its name,
    # otherwise search through several dirs for it.
    #
    # [rvars] a list of requied variables in the config
    #
    # Return a loaded filename or nil on error.
    def config_flat_load(rvars)
      p = ->(f) {
        if File.readable?(f)
          begin
            myconf = YAML.load_file(f)
          rescue
            abort("cannot parse #{f}: #{$!}")
          end
          rvars.each { |i|
            fail "missing or nil '#{i}' in #{f}" if ! myconf.key?(i.to_sym) || ! myconf[i.to_sym]
          }
          @conf.merge!(myconf)
          return @conf[:config]
        end
        return nil
      }

      if @conf[:config].index('/')
        return p.call(@config[:config])
      else
        @conf[:config_dirs].each {|dir|
          return dir+'/'+@conf[:config] if p.call(dir + '/' + @conf[:config])
        }
      end

      return nil
    end


    # Parses CL-like options.
    #
    # [src] An array of options (usually +ARGV+).
    #
    # If _o_ is non nil function parses _src_ immediately, otherwise it
    # only creates +OptionParser+ object and return it (if _simple_ is
    # false).
    def cl_parse(src, o = nil, simple = false)
      if ! o then
#        puts "NEW o (#{cl_opt_protect})" + src.to_s 
        o = OptionParser.new
        o.banner = @conf[:banner]
        o.on('-v', 'Be more verbose.') { |i|
#          puts "cl_parsing_times "+cl_parsing_times.to_s
          @conf[:verbose] += 1 unless cl_opt_protect
        }
        o.on('-V', 'Show version & exit.') { |i|
          puts Meta::VERSION
          exit 0
        }
        o.on('--config NAME', "Set a config name (default is #{@conf[:config]})") {|i|
          @conf[:config] = i
        }
        o.on('--config-dirs', 'Show possible config locations') {
          @conf[:config_dirs].each { |j|
            f = j + '/' + @conf[:config]
            puts (File.readable?(f) ? '* ' : '  ') +  f
          }
          exit 0
        }

        return o if ! simple
      end

      begin
        o.parse!(src)
        @cl_parsing_times += 1
      rescue
        Trestle.errx(1, $!.to_s)
      end
    end
    
  end # trestle
end

# Don't remove this: falsework/0.2.2/naive/2010-12-26T04:50:00+02:00

#!/usr/bin/env ruby

require 'open3'
require 'fileutils'
require 'getoptlong'
include FileUtils::Verbose

require ENV['TM_SUPPORT_PATH'] + "/lib/exit_codes"
require ENV['TM_SUPPORT_PATH'] + "/lib/escape"

require ENV["TM_SUPPORT_PATH"] + "/lib/tm/require_cmd"

debug = false
use_gcc = false
build_package = false
compiler = '6g'
linker = '6l'
binext = '6'
cflags = []
lflags = []

opts = GetoptLong.new(
  ['--use-gcc', '-g', GetoptLong::NO_ARGUMENT],
  ['--compiler-prefix', '-p', GetoptLong::REQUIRED_ARGUMENT],
  ['--build-package', '-b', GetoptLong::NO_ARGUMENT],
  ['--debug', '-d', GetoptLong::NO_ARGUMENT],
  ['--cflags', '-c', GetoptLong::REQUIRED_ARGUMENT],
  ['--lflags', '-l', GetoptLong::REQUIRED_ARGUMENT],
  ['--version', '-v', GetoptLong::NO_ARGUMENT]
)

opts.each do |opt, arg|
  case opt
  when '--use-gcc'
    use_gcc = true
  when '--debug'
    debug = true
  when '--compiler-prefix'
    compiler = "#{arg}g"
    linker = "#{arg}l"
    binext = arg
  when '--build-package'
    build_package = true
  when '--cflags'
    cflags = arg.split(' ')
  when '--lflags'
    lflags = arg.split(' ')
  when '--version'
    print "Version 1.0.0"
    exit 0
  end
end

puts "using #{compiler} and #{linker}" if debug

TextMate.require_cmd compiler
TextMate.require_cmd linker

if ARGV.count < 1
  print 'No input file specified'
  exit 65
end

filepath = ARGV.shift
base = filepath.chomp(File.extname(filepath))
puts "Using base file path #{base}" if debug

cmd = "#{compiler} #{cflags.join(' ')} #{filepath}"

unless use_gcc
  # run the compiler to generate xxx.6 from xxx.go
  puts cmd if debug
  output = `#{cmd}`
  unless output.empty?
    print output
    exit 1
  end
  
  cmd = ''
  if build_package
    # run gopack to create the package archive
    cmd = "gopack grcv #{base}.a #{base}.#{binext}"
  else
    #run the linker to generate xxx from xxx.6
    cmd = "#{linker} #{lflags.join(' ')} -o #{base} #{base}.#{binext}"
  end
  
  puts cmd if debug || build_package
  output = `#{cmd}`
  `rm #{base}.#{binext}`
  
  unless output.empty?
    print output
    exit (build_package ? 0 : 1)
  end
else
  output = `#{args.join(' ')}`
  unless output.empty?
    print output
    exit 1
  end
end

print `#{base}` unless build_package
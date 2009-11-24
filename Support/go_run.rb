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
compiler = '6g'
linker = '6l'
binext = '6'
cflags = []
lflags = []

opts = GetoptLong.new(
  ['--use-gcc', '-g', GetoptLong::NO_ARGUMENT],
  ['--compiler-prefix', '-p', GetoptLong::REQUIRED_ARGUMENT],
  ['--debug', '-d', GetoptLong::NO_ARGUMENT],
  ['--cflags', '-c', GetoptLong::REQUIRED_ARGUMENT],
  ['--lflags', '-l', GetoptLong::REQUIRED_ARGUMENT]
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
  when '--cflags'
    cflags = arg.split(' ')
  when '--lflags'
    lflags = arg.split(' ')
  end
end

puts "using #{compiler} and #{linker}" if debug

TextMate.require_cmd compiler
TextMate.require_cmd linker

if ARGV.count < 1
  print 'No input file specified'
  exit 65
end

filepath = ARGV[0]
base = filepath.chomp(File.extname(filepath))
puts "Using base file path #{base}" if debug

cmd = "#{compiler} #{cflags.join(' ')} #{filepath}"

unless use_gcc
  # run the compiler to generate xxx.6 from xxx.go
  puts "#{cmd}" if debug
  output = `#{cmd}`
  unless output.empty?
    print output
    exit 1
  end
  #run the linker to generate xxx from xxx.6
  cmd = "#{linker} #{lflags.join(' ')} #{base}.#{binext}"
  puts "#{cmd}" if debug
  output = `#{cmd}`
  `rm #{base}.#{binext}`
  unless output.empty?
    print output
    exit 1
  end
else
  output = `#{args.join(' ')}`
  unless output.empty?
    print output
    exit 1
  end
end

print `#{base}`
#!/usr/bin/env ruby

require 'open3'
require 'fileutils'
include FileUtils::Verbose

require ENV['TM_SUPPORT_PATH'] + "/lib/exit_codes"
require ENV['TM_SUPPORT_PATH'] + "/lib/escape"

require ENV["TM_SUPPORT_PATH"] + "/lib/tm/require_cmd"

Debug = false

machine = `sysctl hw.machine | awk -F" " '{print $2}'`
is64Bit = `sysctl hw.optional.x86_64 | awk -F" " '{print $2}'`

compiler = '6g'
linker = '6l'
binext = '6'

use_gcc = (ENV['TM_GO_USE_GCC'] == '1')
if use_gcc
  compiler = 'gcc'
else
  case machine
  when 'arm'
    compiler = '5g'
    linker = '5l'
    binext = '5'
  when 'i386'
    if is64Bit == 0
      compiler = '8g'
      linker = '8l'
      binext = '8'
    end
  end
end

puts "using #{compiler} and #{linker}" if Debug

TextMate.require_cmd compiler
TextMate.require_cmd linker

if ARGV.count < 1
  print 'No input file specified'
  exit 65
end

filepath = ARGV[0]
base = filepath.chomp(File.extname(filepath))
puts "Using base file path #{base}" if Debug

cflags = (ENV["TM_GO_CFLAGS"] || '').split(' ')
lflags = (ENV["TM_GO_LFLAGS"] || '').split(' ')
if lflags.nil?
  lflags = ['-o', "#{base}"]
else
  lflags << '-o' << "#{base}"
end

cmd = "#{compiler} #{cflags.join(' ')} #{filepath}"

unless use_gcc
  # run the compiler to generate xxx.6 from xxx.go
  puts "#{cmd}" if Debug
  output = `#{cmd}`
  unless output.empty?
    print output
    exit 1
  end
  #run the linker to generate xxx from xxx.6
  cmd = "#{linker} #{lflags.join(' ')} #{base}.#{binext}"
  puts "#{cmd}" if Debug
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
#!/usr/bin/env ruby

SUPPORT = ENV['TM_SUPPORT_PATH']
require "#{SUPPORT}/lib/escape"
require "#{SUPPORT}/lib/tm/executor"
require "#{SUPPORT}/lib/tm/save_current_document"

TextMate.save_current_document('go')
TextMate::Executor.make_project_master_current_document

def gomate(tool, verb = nil)
  tool = "#{ENV['TM_BUNDLE_SUPPORT']}/#{tool}"
  file = ENV['TM_FILEPATH']
  opts = {:interactive_input => false}
  opts[:verb] = verb  if verb
  TextMate::Executor.run(tool, file, opts)
end

#!/usr/bin/env ruby

require "#{ENV['TM_SUPPORT_PATH']}/lib/tm/executor"
require "#{ENV['TM_SUPPORT_PATH']}/lib/tm/save_current_document"
require "#{ENV['TM_BUNDLE_SUPPORT']}/goerrs"

TextMate.save_current_document('go')
TextMate::Executor.make_project_master_current_document

def gomate(tool, verb = nil)
  tool = "#{ENV['TM_BUNDLE_SUPPORT']}/#{tool}"
  file = ENV['TM_FILEPATH']
  opts = {:interactive_input => false}
  opts[:verb] = verb  if verb
  TextMate::Executor.run(tool, file, opts) do |str, type|
    Go::link_errs(str, type)
  end
end

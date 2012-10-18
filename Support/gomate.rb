#!/usr/bin/env ruby

require "#{ENV['TM_SUPPORT_PATH']}/lib/escape"
require "#{ENV['TM_SUPPORT_PATH']}/lib/exit_codes"
require "#{ENV['TM_SUPPORT_PATH']}/lib/ui"
require "#{ENV['TM_SUPPORT_PATH']}/lib/web_preview"
require "#{ENV['TM_SUPPORT_PATH']}/lib/tm/executor"
require "#{ENV['TM_SUPPORT_PATH']}/lib/tm/require_cmd"
require "#{ENV['TM_SUPPORT_PATH']}/lib/tm/save_current_document"
require "#{ENV['TM_BUNDLE_SUPPORT']}/goerrs"

# TextMate's special GOPATH used in .tm_properties files prepended to the environment's GOPATH
ENV['GOPATH'] = (ENV.has_key?('TM_GOPATH') ? ENV['TM_GOPATH'] : '') +
                (ENV.has_key?('GOPATH') ? ':' + ENV['GOPATH'] : '')

module Go
  def Go::go(command, options={})
    # TextMate's special TM_GO or expect 'go' on PATH
    go_cmd = ENV['TM_GO'] || 'go'
    TextMate.require_cmd(go_cmd)
    TextMate.save_current_document('go')
    TextMate::Executor.make_project_master_current_document

    args = options[:args] ? options[:args] : []
    opts = {:interactive_input => false, :use_hashbang => false, :version_args => ['version'], :version_regex => /\Ago version (.*)/}
    opts[:verb] = options[:verb] if options[:verb]

    # At this time, we will always run 'go' against a single file.  In the future there may be new
    # commands that will invalidate this but until then, might as well start simple.
    args.push(ENV['TM_FILEPATH'])
    args.push(opts)

    TextMate::Executor.run(go_cmd, command, *args) do |str, type|
      Go::link_errs(str, type)
    end
  end

  def Go::godoc
    # TextMate's special TM_GODOC or expect 'godoc' on PATH
    godoc_cmd = ENV['TM_GODOC'] || 'godoc'
    term = STDIN.read.strip
    TextMate.require_cmd(godoc_cmd)
    TextMate.save_current_document('go')
    TextMate::Executor.make_project_master_current_document

    if term.nil? || term.empty?
      term = TextMate::UI.request_string( :title => 'Go Documentation Search',
                                          :prompt => 'Enter a term to search for:',
                                          :button1 => 'Search')
    end

    TextMate.exit_show_tool_tip('Please select a term to look up.') if term.nil? || term.empty?

    args = []
    args.push(godoc_cmd)
    args.push('-html')
    args.push('-tabwidth=0')
    args.concat term.split('.')
    args.push({:interactive_input => false, :use_hashbang => false})

    out, err = TextMate::Process.run(*args)

    if err.nil? || err == ''
      html_header("Documentation for #{term}", "go")
      puts out
      html_footer
      TextMate.exit_show_html
    else
      TextMate.exit_show_tool_tip(err)
    end
  end

  def Go::gofmt
    # TextMate's special TM_GOFMT or expect 'gofmt' on PATH
    gofmt_cmd = ENV['TM_GOFMT'] || 'gofmt'
    TextMate.require_cmd(gofmt_cmd)
    TextMate.save_current_document('go')
    TextMate::Executor.make_project_master_current_document

    args = []
    args.push(gofmt_cmd)
    args.push("-tabwidth=#{ENV['TM_TAB_SIZE']}")
    if ENV['TM_SOFT_TABS'] && ENV['TM_SOFT_TABS'] == 'YES'
      args.push('-tabs=true')
    else
      args.push('-tabs=false')
    end
    args.push(ENV['TM_FILEPATH'])
    args.push({:interactive_input => false, :use_hashbang => false})

    out, err = TextMate::Process.run(*args)

    if err.nil? || err == ''
      puts out
    else
      html_header("Formatting \"#{ENV['TM_FILENAME']}\"...", "go",
                  # html_head below is used to style the error lines like those displayed when a compiler error occurs
                  :html_head => '<style type="text/css">.err { color: red; } pre { font-style: normal; white-space: normal; }</style>')
      puts '<pre>'
      puts Go::link_errs(err, :err)
      puts '</pre>'
      html_footer
      TextMate.exit_show_html
    end
  end
end


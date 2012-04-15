#!/usr/bin/env ruby

require "#{ENV['TM_SUPPORT_PATH']}/lib/escape"
require "#{ENV['TM_SUPPORT_PATH']}/lib/exit_codes"
require "#{ENV['TM_SUPPORT_PATH']}/lib/tm/executor"
require "#{ENV['TM_SUPPORT_PATH']}/lib/tm/require_cmd"
require "#{ENV['TM_SUPPORT_PATH']}/lib/tm/save_current_document"
require "#{ENV['TM_BUNDLE_SUPPORT']}/goerrs"

module Go
  def Go::get_package_name(filename)
    if ENV['GOPATH']
      dirname = File.dirname File.expand_path filename
      package = ENV['GOPATH'].split(/:/).map do |path|
        root = (File.expand_path path) + '/src/'
        dirname[root.length..-1] if dirname.start_with? root
      end.compact.first
      return package if package
    end

    title = "Can't find package name for file"
    TextMate::HTMLOutput.show(:title => title) do |io|
      gopath = "<code>GOPATH</code>"
      io << "<p>The current #{gopath} is:</p>"
      io << "<blockquote>"
      (ENV['GOPATH'] or '').split(/:/).each do |path|
        io << htmlize(path + "\n")
      end
      io << "</blockquote>"
      io << "<p>Please consult <a href=\"http://golang.org/doc/code.html#GOPATH\">"
      io << "#{gopath} and workspaces</a> in the Go documentation.</p>"
    end
    TextMate.exit_show_html
  end

  def Go::get_target_name(filename, scope)
    case scope
    when :package
      package = get_package_name(filename)
      ENV['TM_DISPLAYNAME'] = package
      return package
    else
      return filename
    end
  end

  def Go::execute(tool, options={})
  end

  def Go::launch(command, options={})
    TextMate.require_cmd("go")
    TextMate.save_current_document("go")
    TextMate::Executor.make_project_master_current_document

    args = options[:args] ? options[:args] : []
    name = get_target_name(ENV['TM_FILEPATH'], options[:scope])
    opts = {:interactive_input => false, :use_hashbang => false}
    opts[:verb] = options[:verb] if options[:verb]

    args.push(name)
    args.push(opts)

    TextMate::Executor.run(go, "command", *args) do |str, type|
      Go::link_errs(str, type)
    end
  end

  def Go::format
    TextMate.require_cmd("gofmt")
    TextMate.save_current_document("go")
    TextMate::Executor.make_project_master_current_document

    args = []
    args.push("gofmt")
    args.push("-tabwidth=#{ENV['TM_TAB_SIZE']}")
    args.push("-tabs=#{ENV['TM_SOFT_TABS'] != 'YES'}")
    args.push(ENV['TM_FILEPATH'])
    args.push({:interactive_input => false, :use_hashbang => false})
    TextMate::Process.run(*args) do |str, type|
      STDOUT << str if type == :out
    end
  end
end


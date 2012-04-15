#!/usr/bin/env ruby

require "#{ENV['TM_SUPPORT_PATH']}/lib/escape"
require "pathname"

module Go
  def Go::normalize_file(file)
    return nil if file == 'untitled'
    return file if Pathname.new(file).absolute?
    base = ENV['TM_PROJECT_DIRECTORY'] || ENV['TM_DIRECTORY'] || Dir.getwd
    File.join(base, file)
  end

  def Go::href(file, line)
    file = normalize_file(file)
    link = "txmt://open?line=#{line}"
    link << "&url=file://#{e_url(file)}" if file
    link
  end

  def Go::link_errs(str, type)
    str.gsub!(/^(.+):(\d+):\s+(.+)$/) do
      file, line, msg = $1, $2, $3
      text = "<a href=\"#{href(file, line)}\">"
      text << "#{htmlize(File.basename(file))}:#{line}</a>"
      text << ": <span class=\"err\">#{htmlize(msg)}</span><br>"
      text
    end
  end
end

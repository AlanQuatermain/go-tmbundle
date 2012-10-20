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
    if str.count(':') == 2
      str.gsub!(/^(.+):(\d+):\s+(.+)$/) do
        file, line, msg = $1, $2, $3
        text = "<a href=\"#{href(File.basename(file), line)}\">"
        text << "#{htmlize(File.basename(file))}:#{line}</a>"
        text << ": <span class=\"err\">#{htmlize(msg)}</span><br>"
        text
      end
    else
      str.gsub!(/^(.+):(\d+):(\d+):\s+(.+)$/) do
        file, line, col, msg = $1, $2, $3, $4
        text = "<a href=\"#{href(File.basename(file), line)}\">"
        text << "#{htmlize(File.basename(file))}:#{line}</a>"
        text << ": <span class=\"err\">#{htmlize(msg)}</span><br>"
        text
      end
    end
  end
end

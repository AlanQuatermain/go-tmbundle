#!/usr/bin/env ruby

# require "#{ENV['TM_SUPPORT_PATH']}/lib/Builder"
require "#{ENV['TM_BUNDLE_SUPPORT']}/Builder"
require "#{ENV['TM_SUPPORT_PATH']}/lib/escape"
require "pathname"

module Go
  def Go::normalize_file(file)
    return nil  if file == 'untitled'
    return file if Pathname.new(file).absolute?
    base = ENV['TM_PROJECT_DIRECTORY'] || ENV['TM_DIRECTORY'] || Dir.getwd
    File.join(base, file)
  end

  def Go::href(file, line)
    file = normalize_file(file)
    link = "txmt://open?line=#{line}"
    link << "&url=file://#{e_url(file)}"  if file
    link
  end

  def Go::link_errs(str, type)
    return  unless type == :err
    xml = Builder::XmlMarkup.new
    str.gsub!(/^(.+):(\d+):\s+(.+)$/) do
      file, line, msg = $1, $2, $3
      xml.a("#{htmlize(File.basename(file))}:#{line}", :href => href(file, line))
      xml.text(': ')
      xml.span(htmlize(msg), :class => "err")
      xml.br
    end
  end
end

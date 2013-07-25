#!/usr/bin/env ruby
# -*- encoding: UTF-8 -*-
#--
# Copyright (C) 2012 Lapis Lazuli Texts
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>.

require "optparse"

require_relative File.join("..", "platform")
require_relative File.join("..", "text_formatter")
require_relative File.join("..", "version")

module Sanzang::Command

  # This class provides a command for text reformatting for CJK languages. This
  # reformatting is typically for use prior to processing the text with the
  # translation commands. The reason for doing this is so that initial text
  # transformations will be done to ensure (1) that terms will be translated
  # reliably, and (2) that the final output of the translation will be readable
  # by the user (i.e. lines not too long).
  #
  class Reflow

    # Create a new instance of the reflow command.
    #
    def initialize
      @name = "sanzang reflow"
      @encoding = Sanzang::Platform.data_encoding
      @infile = nil
      @outfile = nil
      @verbose = false
    end

    # Run the reflow command with the given arguments. The parameter _args_
    # would typically be an array of command options and parameters. Calling
    # this with the "-h" or "--help" option will print full usage information
    # necessary for running this command.
    #
    def run(args)
      parser = option_parser
      parser.parse!(args)

      if args.length != 0
        $stderr.puts(parser)
        return 1
      end

      begin
        fin = @infile ? File.open(@infile, "r") : $stdin
        fin.binmode.set_encoding(@encoding)
        fout = @outfile ? File.open(@outfile, "w") : $stdout
        fout.binmode.set_encoding(@encoding)
        fout.write(Sanzang::TextFormatter.new.reflow_cjk(fin.read))
      ensure
        if defined?(fin) and fin != $stdin
          fin.close if not fin.closed?
        end
        if defined?(fout) and fin != $stdout
          fout.close if not fout.closed?
        end
      end

      return 0
    rescue SystemExit => err
      return err.status
    rescue Errno::EPIPE
      return 0
    rescue Exception => err
      if @verbose
        $stderr.puts err.backtrace
      end
      $stderr.puts "#{@name.split[0]}: #{err.inspect}"
      return 1
    end

    # The name of the command
    #
    attr_reader :name

    private

    # An OptionParser for the command
    #
    def option_parser
      OptionParser.new do |op|
        op.banner = "Usage: #{@name} [options]\n"

        op.banner << "\nReformat text into lines based on spacing, "
        op.banner << "punctuation, etc. This should work\nfor the CJK "
        op.banner << "languages (Chinese, Japanese, and Korean). By default, "
        op.banner << "text is read\nfrom STDIN and written to STDOUT."
        op.banner << "\n"

        op.banner << "\nOptions:\n"

        op.on("-h", "--help", "show this help message and exit") do |v|
          puts op
          exit 0
        end
        op.on("-E", "--encoding=ENC", "set data encoding to ENC") do |v|
          @encoding = Encoding.find(v)
        end
        op.on("-L", "--list-encodings", "list possible encodings") do |v|
          Sanzang::Platform.valid_encodings.each {|e| puts e.to_s }
          exit 0
        end
        op.on("-i", "--infile=FILE", "read input text from FILE") do |v|
          @infile = v
        end
        op.on("-o", "--outfile=FILE", "write output text to FILE") do |v|
          @outfile = v
        end
        op.on("-v", "--verbose", "verbose mode for debugging") do |v|
          @verbose = true
        end
      end
    end

  end
end

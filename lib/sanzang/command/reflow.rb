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

require_relative File.join("..", "text_formatter")
require_relative File.join("..", "version")

module Sanzang::Command

  # The Sanzang::Command::Reflow class provides a Unix-style command for
  # text reformatting. This reformatting is typically for use prior to
  # processing the text with the Sanzang::Command::Translate. The reason for
  # this is to do initial text transformations to ensure (1) that terms will
  # be translated reliably, and (2) that the final output of the translation
  # will be readable by the user (i.e. lines not too long).
  #
  class Reflow

    # Create a new instance of the Reflow class.
    #
    def initialize
      @name = "sanzang-reflow"
      @encoding = Encoding.default_external
      @infile = nil
      @outfile = nil
    end

    # Run the Reflow command with the given arguments. The parameter _args_
    # would typically be an Array of Unix-style command parameters. Calling
    # this with the "-h" or "--help" option will print full usage information
    # necessary for running this command.
    #
    def run(args)
      parser = option_parser
      parser.parse!(args)

      if args.length != 0
        puts(parser)
        return 1
      end

      set_data_encoding

      begin
        fin = @infile ? File.open(@infile, "r") : $stdin
        fin.binmode.set_encoding(@encoding)
        fout = @outfile ? File.open(@outfile, "w") : $stdout
        fout.binmode.set_encoding(@encoding)
        fout.write(Sanzang::TextFormatter.new.reflow_cjk_text(fin.read))
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
    rescue Exception => err
      $stderr.puts err.backtrace
      $stderr.puts "ERROR: #{err.inspect}"
      return 1
    end

    private

    def set_data_encoding
      if @encoding == nil
        if Encoding.default_external == Encoding::IBM437
          $stderr.puts "Switching to UTF-8 for text data encoding."
          @encoding = Encoding::UTF_8
        else
          @encoding = Encoding.default_external
        end
      end
    end

    def option_parser
      OptionParser.new do |pr|
        pr.banner = "Usage: #{@name} [options]\n"

        pr.banner << "\nReformat text file contents into lines based on "
        pr.banner << "spacing, punctuation, etc.\n"
        pr.banner << "\nExamples:\n"
        pr.banner << "    #{@name} -i in/mytext.txt -o out/mytext.txt\n"
        pr.banner << "\nOptions:\n"

        pr.on("-h", "--help", "show this help message and exit") do |v|
          puts pr
          exit 0
        end
        pr.on("-E", "--encoding=ENC", "set data encoding to ENC") do |v|
          @encoding = Encoding.find(v)
        end
        pr.on("-L", "--list-encodings", "list possible encodings") do |v|
          puts(Encoding.list.collect {|e| e.to_s }.sort)
          exit 0
        end
        pr.on("-i", "--infile=FILE", "read input text from FILE") do |v|
          @infile = v
        end
        pr.on("-o", "--outfile=FILE", "write output text to FILE") do |v|
          @outfile = v
        end
        pr.on("-V", "--version", "show version number and exit") do |v|
          puts "Sanzang version: #{Sanzang::VERSION}"
          exit 0
        end
      end
    end

    # The standard name for the command.
    #
    attr_reader :name

  end
end

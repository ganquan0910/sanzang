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

require_relative File.join("..", "translation_table")
require_relative File.join("..", "translator")
require_relative File.join("..", "version")

module Sanzang::Command

  # The Sanzang::Command::Reflow class provides a Unix-style command for
  # text reformatting. This reformatting is typically for use prior to
  # processing the text with the Sanzang::Command::Translate. The reason for
  # this is to do initial text transformations to ensure (1) that terms will
  # be translated reliably, and (2) that the final output of the translation
  # will be readable by the user (i.e. lines not too long).
  #
  class Translate

    # Create a new instance of the Translate class.
    #
    def initialize
      @name = "sanzang-translate"
      @encoding = nil
      @batch_dir = nil
      @infile = nil
      @outfile = nil
    end

    # Run the Translate command with the given arguments. The parameter _args_
    # would typically be an Array of Unix-style command parameters. Calling
    # this with the "-h" or "--help" option will print full usage information
    # necessary for running this command.
    #
    def run(args)
      parser = option_parser
      parser.parse!(args)

      if args.length != 1
        puts parser
        return 1
      end

      set_data_encoding

      translator = nil
      File.open(args[0], "rb", encoding: @encoding) do |table_file|
        table = Sanzang::TranslationTable.new(table_file)
        translator = Sanzang::Translator.new(table)
      end

      if @batch_dir != nil
        $stderr.puts "Batch mode (#{translator.processor_count} processors)"
        if not translator.runs_parallel?
          warn 'Gem not available: "parallel"'
        end
        puts translator.translate_batch($stdin.readlines, @batch_dir)
      else
        begin
          fin = @infile ? File.open(@infile, "rb") : $stdin
          fin.binmode.set_encoding(@encoding)
          fout = @outfile ? File.open(@outfile, "wb") : $stdout
          fout.binmode.set_encoding(@encoding)
          translator.translate_io(fin, fout)
        ensure
          if defined?(fin) and fin != $stdin
            fin.close if not fin.closed?
          end
          if defined?(fout) and fin != $stdout
            fout.close if not fout.closed?
          end
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
        pr.banner = "Usage: #{@name} [options] table\n"
        pr.banner << "Usage: #{@name} -B output_dir table < file_list\n"

        pr.banner << "\nTranslate text using simple table rules. Input text "
        pr.banner << "is read from STDIN by\ndefault, and the output is "
        pr.banner << "written to STDOUT by default. In batch mode, the \n"
        pr.banner << "program reads file paths from STDIN, and writes them "
        pr.banner << "to an output directory.\n"

        pr.banner << "\nExamples:\n"
        pr.banner << "    #{@name} -i text.txt -o text.sz.txt table.txt\n"
        pr.banner << "    #{@name} -B output_dir table.txt < myfiles.txt\n"
        pr.banner << "\nOptions:\n"

        pr.on("-h", "--help", "show this help message and exit") do |v|
          puts pr
          exit 0
        end
        pr.on("-B", "--batch-dir=DIR", "process from a queue into DIR") do |v|
          @batch_dir = v
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
        pr.on("-P", "--platform", "show platform information") do |v|
          puts "Ruby version: #{RUBY_VERSION}"
          puts "Ruby platform: #{RUBY_PLATFORM}"
          puts "External encoding: #{Encoding::default_external}"
          if Encoding::default_internal != nil
            puts "Internal encoding: #{Encoding::default_internal}"
          end
          exit 0
        end
        pr.on("-V", "--version", "show version number and exit") do |v|
          puts "Sanzang version: #{Sanzang::VERSION}"
          exit 0
        end
      end
    end

    attr_reader :name

  end
end

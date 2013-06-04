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

  # This class provides a command for simple translation of one file or text.
  # Input and output text can be read from either stdin and stdout, or from
  # files. For mass translation of texts, see Sanzang::Command::Batch.
  #
  class Translate

    # Create a new instance of the Translate class.
    #
    def initialize
      @name = "sanzang translate"
      @encoding = nil
      @infile = nil
      @outfile = nil
      @verbose = false
    end

    # Get a list of all acceptable text encodings.
    #
    def valid_encodings
      all_enc = Encoding.list.collect {|e| e.to_s }.sort do |x,y|
        x.upcase <=> y.upcase
      end
      all_enc.find_all do |e|
        begin
          Encoding::Converter.search_convpath(e, Encoding::UTF_8)
        rescue Encoding::ConverterNotFoundError
          e == "UTF-8" ? true : false
        end
      end
    end

    # Run the translate command with the given arguments. The parameter _args_
    # would typically be an array of command options and parameters. Calling
    # this with the "-h" or "--help" option will print full usage information
    # necessary for running this command.
    #
    def run(args)
      parser = option_parser
      parser.parse!(args)

      if args.length != 1
        $stderr.puts parser
        return 1
      end

      set_data_encoding

      translator = nil
      File.open(args[0], "rb", encoding: @encoding) do |table_file|
        table = Sanzang::TranslationTable.new(table_file.read)
        translator = Sanzang::Translator.new(table)
      end

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

      return 0
    rescue SystemExit => err
      return err.status
    rescue Errno::EPIPE
      return 0
    rescue Exception => err
      if @verbose
        $stderr.puts err.backtrace
      end
      $stderr.puts err.inspect
      return 1
    end

    private

    # Initialize the encoding for text data if it is not already set
    #
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

    # An OptionParser for the command
    #
    def option_parser
      OptionParser.new do |op|
        op.banner = "Usage: #{@name} [options] table\n"

        op.banner << "\nTranslate text using simple table rules. Input text "
        op.banner << "is read from STDIN by\ndefault, and the output is "
        op.banner << "written to STDOUT by default.\n"

        op.banner << "\nExample:\n"
        op.banner << "    #{@name} -i text.txt -o text.sz.txt table.txt\n"
        op.banner << "\nOptions:\n"

        op.on("-h", "--help", "show this help message and exit") do |v|
          puts op
          exit 0
        end
        op.on("-E", "--encoding=ENC", "set data encoding to ENC") do |v|
          @encoding = Encoding.find(v)
        end
        op.on("-L", "--list-encodings", "list possible encodings") do |v|
          puts valid_encodings
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

    # Name of the command
    #
    attr_reader :name

  end
end

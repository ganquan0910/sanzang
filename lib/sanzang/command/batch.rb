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
require_relative File.join("..", "batch_translator")
require_relative File.join("..", "version")

module Sanzang::Command

  # This class implements a command for batch translation of texts. The command
  # presumes that the list of input files will be read from $stdin, while the
  # output files will be written to a single directory. Usage information can
  # be accessed by passing in the "-h" or "--help" options.
  #
  class Batch

    # Create a new instance of the batch command.
    #
    def initialize
      @name = "sanzang batch"
      @encoding = nil
      @outdir = nil
      @jobs = nil
    end

    # Run the batch command with the given arguments. The parameter _args_
    # would typically be an array of command options and parameters. Calling
    # this method with the "-h" or "--help" option will print full usage
    # information necessary for running the command. This method will return
    # either 0 (success) or 1 (failure).
    #
    def run(args)
      parser = option_parser
      parser.parse!(args)

      if args.length != 2
        $stderr.puts parser
        return 1
      end

      set_data_encoding

      translator = nil
      File.open(args[0], "rb", encoding: @encoding) do |table_file|
        table = Sanzang::TranslationTable.new(table_file.read)
        translator = Sanzang::BatchTranslator.new(table)
      end

      $stdin.binmode.set_encoding(@encoding)
      puts translator.translate_to_dir($stdin.read.split, args[1], true, @jobs)
      return 0
    rescue SystemExit => err
      return err.status
    rescue Exception => err
      $stderr.puts err.backtrace
      $stderr.puts "\nERROR: #{err.inspect}\n\n"
      return 1
    end

    private

    # Set the encoding for text data if it is not already set
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

    # Return an OptionParser object for this command
    #
    def option_parser
      OptionParser.new do |op|
        op.banner = "Usage: #{@name} [options] table output_dir < queue\n"

        op.banner << "\nBatch translate files concurrently. A list of files "
        op.banner << "is read from STDIN, while\nprogress information is "
        op.banner << "printed to STDERR. The list of output files written is\n"
        op.banner << "printed to STDOUT at the end of the batch. The "
        op.banner << "output directory is specified as\na parameter.\n"

        op.banner << "\nOptions:\n"

        op.on("-h", "--help", "show this help message and exit") do |v|
          puts op
          exit 0
        end
        op.on("-E", "--encoding=ENC", "set data encoding to ENC") do |v|
          @encoding = Encoding.find(v)
        end
        op.on("-L", "--list-encodings", "list possible encodings") do |v|
          encodings = Encoding.list.sort do |x,y|
            x.to_s.upcase <=> y.to_s.upcase
          end
          puts encodings
          exit 0
        end
        op.on("-j", "--jobs=N", "allow N concurrent processes") do |v|
          @jobs = v.to_i
        end
      end
    end

    # Name of the command
    #
    attr_reader :name

  end
end

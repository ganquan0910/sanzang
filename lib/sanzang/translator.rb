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

begin
  require "parallel"
rescue LoadError
  nil
end

module Sanzang

  # Translator is the main class for performing text translations with Sanzang.
  # A Translator utilizes a TranslationTable, which is passed to it at the time
  # of creation. The Translator can then apply these translation rules,
  # generate full translation listings, and perform translations by reading and
  # writing to IO objects. Finally, Translator supports a batch mode that can
  # utilize multiprocessing if the _Parallel_ module is available, and if the
  # platform supports Kernel#fork. Methods are also available for querying the
  # status of this functionality.
  #
  class Translator

    # Creates a new Translator object with the given TranslationTable. The
    # TranslationTable stores rules for translation, while the Translator is
    # the worker who applies these rules and can create translation listings.
    #
    def initialize(translation_table)
      @table = translation_table
    end

    # Returns true if both the _Parallel_ module is available, and is also
    # functioning on this particular implementation of Ruby. Currently the
    # _mingw_ and _mswin_ ports of Ruby do not have Process#fork implemented.
    #
    def runs_parallel?
      if not Process.respond_to?(:fork)
        false
      elsif defined?(Parallel) == "constant" and Parallel.class == Module
        true
      else
        false
      end
    end

    # Return the number of processors available on the current system. This
    # will return the total number of logical processors, rather than physical
    # processors.
    #
    def processor_count
      runs_parallel? == true ? Parallel.processor_count : 1
    end

    # Return an Array of all translation rules used by a particular text.
    # These records represent the vocabulary used by the text.
    #
    def text_vocab(source_text)
      new_table = []
      @table.records.each do |record|
        if source_text.include?(record[0])
          new_table << record
        end
      end
      new_table
    end

    # Use the TranslationTable of the Translator to create translations for
    # each destination language column of the translation table. These
    # result is a simple Array of String objects, with each String object
    # corresponding to a destination language column in the TranslationTable.
    #
    def translate(source_text)
      text_collection = [source_text]
      vocab_terms = text_vocab(source_text)
      1.upto(@table.width - 1) do |column_i|
        translation = String.new(source_text)
        vocab_terms.each do |term|
          translation.gsub!(term[0], term[column_i])
        end
        text_collection << translation
      end
      text_collection
    end

    # Generate a translation listing text string, in which the output of
    # Translator#translate is collated and numbered for reference purposes.
    # This is the normal text listing output of the Sanzang Translator.
    #
    def gen_listing(source_text)
      newline = source_text.include?("\r") ? "\r\n" : "\n"
      texts = translate(source_text).collect {|t| t = t.split(newline) }
      listing = "".encode(source_text.encoding)

      texts[0].length.times do |line_i|
        @table.width.times do |col_i|
          listing << "[#{line_i + 1}.#{col_i + 1}] #{texts[col_i][line_i]}" \
                  << newline
        end
        listing << newline
      end
      listing
    end

    # Read a text from _input_ and write its translation listing to _output_.
    # The parameters _input_ and _output_ can be either String objects or IO
    # objects. If they are strings, then they are interpreted as being file
    # paths. If they are not strings, then the I/O operations are performed on
    # them directly.
    #
    def translate_io(input, output)
      if input.class == String
        input = File.open(input, "r", external_encoding: @table.encoding)
      end
      if output.class == String
        output = File.open(output, "w", external_encoding: @table.encoding)
      end
      output.write(gen_listing(input.read))
      input.close
      output.close
    end

    # Translate a list of files to some output directory. If the _verbose_
    # parameter is true, then print progress to STDERR. If the value of
    # Translator#runs_parallel? is false, then the batch is processed
    # sequentially, only utilizing one processor. However, if the value is
    # true, then run the batch by utilizing the Parallel module for efficient
    # multiprocessing.
    #
    def translate_batch(fpath_list, out_dir, verbose = true)
      fpath_list.collect! {|f| f.chomp }

      if not runs_parallel?
        fpath_list.each do |in_fpath|
          out_fpath = File.join(out_dir, File.basename(in_fpath))
          translate_io(in_fpath, out_fpath)
          if verbose
            $stderr.write "[#{Process.pid}] #{File.expand_path(out_fpath)} \n"
            $stderr.flush
          end
          out_fpath
        end
      else
        Parallel.map(fpath_list) do |in_fpath|
          out_fpath = File.join(out_dir, File.basename(in_fpath))
          translate_io(in_fpath, out_fpath)
          if verbose
            $stderr.write "[#{Process.pid}] #{File.expand_path(out_fpath)} \n"
            $stderr.flush
          end
          out_fpath
        end
      end
    end

    # The TranslationTable used by the Translator
    #
    attr_reader :table

  end
end

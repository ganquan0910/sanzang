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

module Sanzang

  # Translator is the main class for performing text translations with Sanzang.
  # A Translator utilizes a TranslationTable, which is passed to it at the time
  # of creation. The Translator can then apply these translation rules,
  # generate full translation listings, and perform translations by reading and
  # writing to IO objects.
  #
  class Translator

    # Creates a new Translator object with the given TranslationTable. The
    # TranslationTable stores rules for translation, while the Translator is
    # the worker who applies these rules and can create translation listings.
    #
    def initialize(translation_table)
      @table = translation_table
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
    # The parameters _input_ and _output_ should be opened IO objects.
    #
    def translate_io(input, output)
      output.write(gen_listing(input.read))
    end

    # The TranslationTable used by the Translator
    #
    attr_reader :table

  end
end

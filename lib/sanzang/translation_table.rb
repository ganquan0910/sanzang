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
#
module Sanzang

  # TranslationTable encapsulates the set of rules used for translation by
  # Sanzang::Translator. These rules may be loaded from a string passed in to
  # the constructor, or loaded from an open IO object. The translation rules
  # will then go through basic parsing to ensure the table data is in the
  # correct format, and then the rules are reverse sorted by the length of the
  # source language column. Thereafter, these rules are accessible through the
  # ''records'' attribute, and metadata is available through other accessors
  # and methods. It is the responsibility of Sanzang::Translator object to
  # actually apply the rules of a TranslationTable to some text, as the table
  # merely encapsulates a set of translation rules.
  #
  # The format for translation table data can be summarized as the following:
  #
  # * Plain text with one line per record
  # * Records begin with "~|", end with "|~", and are delimited by "|".
  # * The number of columns in each record must be consistent.
  #
  # An example of this format is the following:
  #
  #   ~|zh-term1|en-term1|~
  #   ~|zh-term2|en-term2|~
  #   ~|zh-term3|en-term3|~
  #
  class TranslationTable

    # Create a new TranslationTable object from a string or by reading an IO
    # object. If the table parameter is a kind of string, then attempt to parse
    # the table data from this string. Otherwise treat the parameter as an open
    # IO object, and attempt to read the string data from that. After loading
    # and verifying the contents of the translation table, all the records are
    # reverse sorted by length, since this is the order in which they will be
    # applied.
    #
    def initialize(rules)
      contents = rules.kind_of?(String) ? rules : rules.read
      @encoding = contents.encoding

      left = "~|".encode(@encoding)
      right = "|~".encode(@encoding)
      separator = "|".encode(@encoding)

      @records = contents.gsub("\r", "").split("\n").collect do |rec|
        rec = rec.strip.gsub(left, "").gsub(right, "").split(separator)
      end

      if @records.length > 0
        @width = records[0].length
        0.upto(@records.length - 1) do |i|
          if @records[i].length != @width
            raise "Column mismatch: Line #{i + 1}"
          end
        end
      else
        @width = 0
      end

      @records.sort! {|x,y| y.length <=> x.length }
    end

    # Retrieve a record by its numeric index. This is just shorthand for
    # looking at the records attribute directly.
    #
    def [](index)
      @records[index]
    end

    # Find the record where the source language field is equal to the given
    # parameter.
    #
    def find(term)
      @records.find {|rec| rec[0] == term }
    end

    # The number of records in the translation table (the table length).
    #
    def length
      @records.length
    end

    # The number of columns in the translation table (the table width).
    #
    attr_reader :width

    # The records for the translation table, as an Array.
    #
    attr_reader :records

    # The text encoding used for all translation table data.
    #
    attr_reader :encoding

  end
end

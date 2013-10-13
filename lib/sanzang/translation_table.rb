#!/usr/bin/env ruby
# -*- encoding: UTF-8 -*-
#--
# Copyright (C) 2012-2013 Lapis Lazuli Texts
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

  # A translation table encapsulates a set of rules for translating with
  # the \Sanzang system. These are essentially read-only objects meant for
  # storing well-defined translation table data.
  #
  class TranslationTable

    # A table is created from a formatted string of translation rules. The
    # string is in the format of delimited text. The text format can be
    # summarized as follows:
    #
    # - Each line of text is a record for a translation rule.
    # - Each record may begin with "~|" and end with "|~".
    # - Fields in the record are separated by the "|" character.
    # - The first field contains the term in the source language.
    # - Subsequent fields are equivalent terms in destination languages.
    # - The number of columns must be consistent for the entire table.
    #
    # The first element in a record is a term in the source language, and
    # subsequent elements are are equivalent terms in destination languages.
    # The number of "columns" in a translation table must be consistent across
    # the entire table.
    #
    def initialize(rules)
      contents = rules.kind_of?(String) ? rules : rules.read
      contents.encode!(Encoding::UTF_8)
      contents.strip!
      contents.gsub!(/^\s*|\s*$|\r/, "")
      contents.gsub!("~|", "")
      contents.gsub!("|~", "")
      @records = contents.split("\n").collect {|r| r.split("|") }

      if @records.length < 1
        raise "Table must have at least 1 row"
      elsif @records[0].length < 2
        raise "Table must have at least 2 columns"
      end

      width = records[0].length
      @records.each do |r|
        if r.length != width
          raise "Column mismatch: Line #{i + 1}"
        end
      end

      @records.sort! {|x,y| y[0].length <=> x[0].length }
    end

    # Retrieve a record by its numeric index.
    #
    def [](index)
      @records[index]
    end

    # The text encoding used for all translation table data
    #
    def encoding
      Encoding::UTF_8
    end

    # Find a record by the source language term (first column).
    #
    def find(term)
      @records.find {|rec| rec[0] == term }
    end

    # The number of records in the table
    #
    def length
      @records.length
    end

    # The number of columns in the table
    #
    def width
      @records[0].length
    end

    # The records for the translation table, as an array
    #
    attr_reader :records

  end
end

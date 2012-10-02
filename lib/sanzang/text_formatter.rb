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

  # This class handles formatting of text data especially to prepare the text
  # for direct translation. This involves reformatting and reflowing text so
  # that words are not divided between lines, and so the output is well suited
  # for humans. For practical purposes of readability, lines of text to be
  # translated should be succinct and easily comprehensible. The TextFormatter
  # class includes methods for accomplishing this reformatting.
  #
  class TextFormatter

    # Given a CJK string of text, reformat the string for greater compatibility
    # with direct translation, and reflow the text based on its punctuation.
    # The first step of this reformatting is to remove any CBETA-style margins
    # at the beginning of each line, which are indicated by the double-bar
    # character ("║" U+2551). An extra space is then inserted after each short
    # line which may indicate that the line is part of a poem, and should be
    # kept separate. Following this, all newlines are removed, and the text is
    # then reformatted according to the remaining punctuation and spacing.
    #
    def reflow_cjk_text(s)
      source_encoding = s.encoding
      s.encode!(Encoding::UTF_8)

      # Strip all CBETA-style margins
      s.gsub!(/^.*║/, "")

      # Starts with Hanzi space and short line: add Hanzi space at the end.
      # This is used for avoiding conflicts between poetry and prose.
      s.gsub!(/^(　)(.{1,15})$/, "\\1\\2　")

      # Collapse all vertical whitespace.
      using_crlf = s.include?("\r")
      s.gsub!(/(\r|\n)/, "")

      # Ender followed by non-ender: newline in between.
      s.gsub!(/([：，；。？！」』.;:\?])([^：，；。？！」』.;:\?])/,
        "\\1\n\\2")

      # Non-starter, non-ender, followed by a starter: newline in between.
      s.gsub!(/([^「『　\t：，；。？！」』.;:\?\n])([「『　\t])/,
        "\\1\n\\2")

      if s[-1] != "\n"
        s << "\n"
      end

      s.gsub!("\n", "\r\n") if using_crlf
      s.encode!(source_encoding)
    end

  end
end

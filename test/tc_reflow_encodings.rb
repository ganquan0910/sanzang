#!/usr/bin/env ruby
# -*- encoding: UTF-8 -*-

require "test/unit"

require_relative File.join("..", "lib", "sanzang")

# Test "reflow" operation with all major encodings for conversion and accuracy.
#
# Most encodings deemed as "important" here are Unicode encodings and those
# commonly used for Chinese. Some encodings do not function due to converters
# for these encodings being unimplemented in Ruby 1.9. Such encodings include
# the following:
#
# * EUC-TW (Traditional Chinese)
#
class TestReflowEncodings < Test::Unit::TestCase

  # Han characters, traditional, including a CBETA-style margin, which should
  # be automatically stripped out by the text formatter.
  #
  def reflow_zh_hant(encoding)
    text_s1 = "T31n1586_p0060a19(00)║　　　　大唐三藏法師玄奘奉　詔譯"
    text_s2 = "　　　　大唐三藏法師玄奘奉\n　詔譯\n　\n"
    text_s1.encode!(encoding)
    text_s2.encode!(encoding)
    formatter = Sanzang::TextFormatter.new
    assert_equal(text_s2, formatter.reflow_cjk(text_s1))
  end

  # Han characters, simplified and without double vertical bar. The margin
  # was dropped from the text due to GB2312 not supporting the "double bar"
  # (U+2551) character.
  #
  def reflow_zh_hans(encoding)
    text_s1 = "　　　　大唐三藏法师玄奘奉　诏译"
    text_s2 = "　　　　大唐三藏法师玄奘奉\n　诏译\n　\n"
    text_s1.encode!(encoding)
    text_s2.encode!(encoding)
    formatter = Sanzang::TextFormatter.new
    assert_equal(text_s2, formatter.reflow_cjk(text_s1))
  end

  # UTF-8 (Traditional Chinese)
  #
  def test_reflow_hanzi_utf_8
    reflow_zh_hant("UTF-8")
  end

  # UTF-16LE (Traditional Chinese)
  #
  def test_reflow_hanzi_utf_16le
    reflow_zh_hant("UTF-16LE")
  end

  # UTF-16BE (Traditional Chinese)
  #
  def test_reflow_hanzi_utf_16be
    reflow_zh_hant("UTF-16BE")
  end

  # UTF-32LE (Traditional Chinese)
  #
  def test_reflow_hanzi_utf_32le
    reflow_zh_hant("UTF-32LE")
  end

  # UTF-32BE (Traditional Chinese)
  #
  def test_reflow_hanzi_utf_32be
    reflow_zh_hant("UTF-32BE")
  end

  # Big5 (Traditional Chinese)
  #
  def test_reflow_hanzi_big5
    reflow_zh_hant("Big5")
  end

  # GB2312 (Simplified Chinese)
  # Double vertical bar glyph (U+2551) is not present in GB2312
  #
  def test_reflow_hanzi_gb2312
    reflow_zh_hans("GB2312")
  end

  # GBK (Traditional Chinese)
  #
  def test_reflow_hanzi_gbk
    reflow_zh_hant("GBK")
  end

  # GB18030 (Traditional Chinese)
  #
  def test_reflow_hanzi_gb18030
    reflow_zh_hant("GB18030")
  end
end

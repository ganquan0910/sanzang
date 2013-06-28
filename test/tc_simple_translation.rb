#!/usr/bin/env ruby
# -*- encoding: UTF-8 -*-

require "test/unit"

require_relative File.join("..", "lib", "sanzang")

class TestSanzang < Test::Unit::TestCase

  def table_string
    "~|三藏| sānzàng| tripiṭaka|~
     ~|法師| fǎshī| dharma-master|~
     ~|玄奘| xuánzàng| xuanzang|~
     ~|奉| fèng| reverently|~
     ~|唐| táng| tang|~
     ~|大| dà| great|~
     ~|詔| zhào| imperial-order|~
     ~|譯| yì| translate/interpret|~"
  end

  def stage_1
    "T31n1586_p0060a19(00)║　　　　大唐三藏法師玄奘奉　詔譯\r\n"
  end

  def stage_2
    "　　　　大唐三藏法師玄奘奉\r\n　詔譯\r\n"
  end

  def stage_3
    "[1.1] 　　　　大唐三藏法師玄奘奉\r\n" \
    << "[1.2] 　　　　 dà táng sānzàng fǎshī xuánzàng fèng\r\n" \
    << "[1.3] 　　　　 great tang tripiṭaka dharma-master xuanzang " \
    << "reverently\r\n" \
    << "\r\n" \
    << "[2.1] 　詔譯\r\n" \
    << "[2.2] 　 zhào yì\r\n" \
    << "[2.3] 　 imperial-order translate/interpret\r\n" \
    << "\r\n"
  end

  def test_translation_table
    table_path = File.join(File.dirname(__FILE__), "utf-8", "table.txt")
    fin = File.open(table_path, "rb", encoding: "UTF-8")
    table = Sanzang::TranslationTable.new(fin.read)
    fin.close
    assert(table.width.class == Fixnum, "Table width undefined")
    assert(table.length.class == Fixnum, "Table length undefined")
    assert(table.records.class == Array, "Table contents not an array")
    rec0_length = table.records[0].length
    table.records.each do |rec|
      assert(rec.class == Array, "Malformed table records")
      assert(rec.length == rec0_length, "Inconsistent table records")
    end
    assert(table.width > 0, "Zero-width table")
    assert(table.length > 0, "Zero-length table")
  end

  def test_reflow_cjk_string
    text = Sanzang::TextFormatter.new.reflow_cjk(stage_1())
    assert_equal(stage_2(), text)
  end

  def test_translate_string
    table = Sanzang::TranslationTable.new(table_string())
    text = Sanzang::Translator.new(table).gen_listing(stage_2())
    assert_equal(stage_3(), text)
  end

  def test_translate_file
    table_path = File.join(File.dirname(__FILE__), "utf-8", "table.txt")
    s2_path = File.join(File.dirname(__FILE__), "utf-8", "stage_2.txt")
    s3_path = File.join(File.dirname(__FILE__), "utf-8", "stage_3.txt")
    tab = Sanzang::TranslationTable.new(IO.read(table_path, encoding: "UTF-8"))
    translator = Sanzang::Translator.new(tab)
    translator.translate_io(s2_path, s3_path)
  end

  def test_translator_parallel
    table = Sanzang::TranslationTable.new(table_string())
    bt = Sanzang::BatchTranslator.new(table)
    bt.forking?
    assert(bt.processor_count > 0, "Processor count less than zero")
  end

  def test_translate_batch
    table = Sanzang::TranslationTable.new(table_string())
    bt = Sanzang::BatchTranslator.new(table)
    bt.translate_to_dir(
        Dir.glob(File.join(File.dirname(__FILE__), "utf-8", "file_*.txt")),
        File.join(File.dirname(__FILE__), "utf-8", "batch"), false)
  end

end

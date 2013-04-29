# -*- encoding: UTF-8 -*-

require "./lib/sanzang/version"

Gem::Specification.new do |s|
  s.required_ruby_version = ">= 1.9.0"
  s.add_dependency("parallel", ">= 0.5.19")

  s.name         = "sanzang"
  s.summary      = "Simple rule-based machine translation system."
  s.version      = Sanzang::VERSION
  s.license      = "GPL-3"

  s.description  = "Sanzang is a program built for machine translation of "
  s.description << "natural languages. This application is particularly "
  s.description << "suitable as a translation aid for CJK languages "
  s.description << "including ancient texts. The translation method is "
  s.description << "rule-based, and translation rules are stored in flat "
  s.description << "files as delimited text. This program can also utilize "
  s.description << "multiprocessing to naturally scale to multiple "
  s.description << "processors and processor cores. Sanzang is available "
  s.description << "under the GNU GPL, version 3."

  s.authors      = ["Lapis Lazuli Texts"]
  s.email        = ["lapislazulitexts@gmail.com"]
  s.homepage     = "http://www.lapislazulitexts.com/sanzang/"

  s.executables  = Dir.glob("bin/**/*").map {|f| File.basename(f) }
  s.files        = Dir.glob("{bin,test,lib}/**/**/*")
  s.require_path = "lib"
  s.test_files   = Dir.glob("test/tc_*.rb")

  s.extra_rdoc_files = ["HACKING", "LICENSE", "MANUAL", "README"]
end

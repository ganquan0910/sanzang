# -*- encoding: UTF-8 -*-

require "./lib/sanzang/version"

Gem::Specification.new do |s|
  s.required_ruby_version = ">= 1.9.0"
  s.add_dependency("parallel", ">= 0.5.19")

  s.name          = "sanzang"
  s.summary       = "Sanzang"
  s.version       = Sanzang::VERSION
  s.license       = "GPL-3"

  s.description   = "Sanzang is an application built for direct machine "
  s.description  << "translation of natural languages. This application is "
  s.description  << "particularly suitable as a translation aid for for "
  s.description  << "ancient Chinese texts. Sanzang uses simple direct "
  s.description  << "translation rules organized into translation tables, "
  s.description  << "which are stored in a straightforward text format. "
  s.description  << "Batch translations utilize multiprocessing to translate "
  s.description  << "files in parallel, naturally scaling to the number of "
  s.description  << "processors available. Sanzang is available under the "
  s.description  << "GNU General Public License, version 3."

  s.authors       = ["Lapis Lazuli Texts"]
  s.email         = ["lapislazulitexts@gmail.com"]
  s.homepage      = "http://www.lapislazulitexts.com"

  s.executables   = Dir.glob("bin/**/*").map {|f| File.basename(f) }
  s.files         = Dir.glob("{bin,test,lib}/**/**/*")
  s.require_path  = "lib"
  s.test_files    = Dir.glob("test/tc_*.rb")

  s.extra_rdoc_files = ["HACKING", "LICENSE", "README"]
  s.rdoc_options  = ["--main", "README", "--title", "Sanzang"]
end

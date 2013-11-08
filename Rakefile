# coding: UTF-8
#
# Note: Building tar/gz and tar/bz2 files has been tested only with GNU tar.
#

require "rdoc/task"
require_relative File.join("lib", "sanzang", "version")

Encoding.default_external = Encoding::UTF_8

task :all => [:test, :clean, :gem]
task :build => [:test, :gem]
task :clean => [:clean_dist, :clean_tests, :clean_rdoc]
task :default => [:test, :gem]
task :dist => [:test, :gem]
task :tar => [:tar_gz, :tar_bz2]

desc "Build RubyGem"
task :gem => :clean_tests do
  mkdir_p "dist"
  sh "gem build sanzang.gemspec"
  Dir.glob("sanzang*.gem").each do |gem|
    mv(gem, File.join("dist", gem))
  end
end

desc "Build tar/gz"
task :tar_gz => [:clean_tests, :clean_rdoc] do
  old_wd = Dir.pwd
  mkdir_p("dist")
  chdir("..")
  tar_fp = File.join("sanzang", "dist", "sanzang-#{Sanzang::VERSION}.tar")
  sh "rm -f #{tar_fp}"
  sh "rm -f #{tar_fp}.bz2"
  sh "find sanzang -type f | grep -Ev '\\.git|/dist' | xargs tar cf #{tar_fp}"
  sh "gzip -9 #{tar_fp}"
  chdir(old_wd)
end

desc "Build tar/bz2"
task :tar_bz2 => [:clean_tests, :clean_rdoc] do
  old_wd = Dir.pwd 
  mkdir_p("dist")
  chdir("..")
  tar_fp = File.join("sanzang", "dist", "sanzang-#{Sanzang::VERSION}.tar")
  sh "rm -f #{tar_fp}"
  sh "rm -f #{tar_fp}.bz2"
  sh "find sanzang -type f | grep -Ev '\\.git|/dist' | xargs tar cf #{tar_fp}"
  sh "bzip2 -9 #{tar_fp}"
  chdir(old_wd)
end

desc "Clean old build files"
task :clean_dist do
  Dir.glob(File.join("dist", "*")) do |dist_file|
    rm dist_file
  end
end

desc "Clean RDoc documentation"
task :clean_rdoc do
  rm_rf "doc"
  rm_rf "html"
end

desc "Clean old test data"
task :clean_tests do
  Dir.glob(File.join("test", "utf-8", "batch", "*.txt")) do |test_file|
    rm test_file
  end
end

desc "Run unit tests"
task :test do
  sh "testrb test/tc_*.rb"
end

desc "Build RDoc documentation"
RDoc::Task.new do |rd|
  rd.title = "Sanzang"
  rd.rdoc_files.include "lib/**/*"
  rd.rdoc_files.include "HACKING.rdoc"
  rd.rdoc_files.include "LICENSE.rdoc"
  rd.rdoc_files.include "MANUAL.rdoc"
  rd.rdoc_files.include "README.rdoc"
end

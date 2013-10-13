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
  FileUtils.mkdir_p("dist")
  Rake.sh "gem build sanzang.gemspec"
  Dir.glob("sanzang*.gem").each do |gem|
    FileUtils.mv(gem, File.join("dist", gem))
  end
end

desc "Build tar/gz"
task :tar_gz => [:clean_tests, :clean_rdoc] do
  old_wd = Dir.pwd
  FileUtils.mkdir_p("dist")
  tar_fpath = File.join(Dir.pwd, "dist", "sanzang-#{Sanzang::VERSION}.tar")
  Rake.sh "rm -f tar_fpath"
  Rake.sh "rm -f #{tar_fpath}.gz"
  Dir.chdir("..")
  tar_opts = "--exclude='.git*' --exclude=dist --exclude=html"
  Rake.sh "tar #{tar_opts} -cf #{tar_fpath} sanzang"
  Rake.sh "gzip -9 #{tar_fpath}"
  Dir.chdir(old_wd)
end

desc "Build tar/bz2"
task :tar_bz2 => [:clean_tests, :clean_rdoc] do
  old_wd = Dir.pwd 
  FileUtils.mkdir_p("dist")
  tar_fpath = File.join(Dir.pwd, "dist", "sanzang-#{Sanzang::VERSION}.tar")
  Rake.sh "rm -f tar_fpath"
  Rake.sh "rm -f #{tar_fpath}.bz2"
  Dir.chdir("..")
  tar_opts = "--exclude='.git*' --exclude=dist --exclude=html"
  Rake.sh "tar #{tar_opts} -cf #{tar_fpath} sanzang"
  Rake.sh "bzip2 -9 #{tar_fpath}"
  Dir.chdir(old_wd)
end

desc "Clean old build files"
task :clean_dist do
  Dir.glob(File.join("dist", "*")) do |dist_file|
    puts "rm: #{dist_file}"
    File.delete dist_file
  end
end

desc "Clean RDoc documentation"
task :clean_rdoc do
  Rake.sh "rm -rf doc"
  Rake.sh "rm -rf html"
end

desc "Clean old test data"
task :clean_tests do
  Dir.glob(File.join("test", "utf-8", "batch", "*.txt")) do |test_file|
    puts "rm: #{test_file}"
    File.delete test_file
  end
end

desc "Run unit tests"
task :test do
  Rake.sh "testrb test/tc_*.rb"
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

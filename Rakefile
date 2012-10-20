#
# Note: Building tar/gz and tar/bz2 files has been tested only with GNU tar.
#

require "rdoc/task"
require "./lib/sanzang/version"

task :all => [:test, :clean, :gem, :tar]
task :build => [:test, :gem]
task :clean => [:clean_dist, :clean_tests]
task :default => [:test, :gem]
task :dist => [:test, :gem]
task :tar => [:tar_gz, :tar_bz2]

desc "Build RubyGem"
task :gem => :clean_tests do
  FileUtils.mkdir_p("dist")
  Rake.sh "gem build sanzang.gemspec"
  Dir.glob("sanzang*.gem").each do |gem|
    FileUtils.mv(gem, File.join("dist", gem))
    puts "\n=> #{File.join("dist", gem)}\n\n"
  end
end

desc "Build tar/gz"
task :tar_gz => :clean_tests do
  FileUtils.mkdir_p("dist")
  old_wd = Dir.pwd
  tar_fpath = File.join(Dir.pwd, "dist", "sanzang-#{Sanzang::VERSION}.tar.gz")
  Dir.chdir("..")
  Rake.sh "tar --exclude='.git*' --exclude=dist -czvf #{tar_fpath} sanzang"
  Dir.chdir(old_wd)
  puts "\n=> #{tar_fpath}\n\n"
end

desc "Build tar/bz2"
task :tar_bz2 => :clean_tests do
  FileUtils.mkdir_p("dist")
  old_wd = Dir.pwd
  tar_fpath = File.join(Dir.pwd, "dist", "sanzang-#{Sanzang::VERSION}.tar.bz2")
  Dir.chdir("..")
  Rake.sh "tar --exclude='.git*' --exclude=dist -cjvf #{tar_fpath} sanzang"
  Dir.chdir(old_wd)
  puts "\n=> #{tar_fpath}\n\n"
end

desc "Clean old build files"
task :clean_dist do
  Dir.glob(File.join("dist", "*")) do |dist_file|
    puts "rm: #{dist_file}"
    File.delete dist_file
  end
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
  rd.rdoc_files.include "HACKING"
  rd.rdoc_files.include "LICENSE"
  rd.rdoc_files.include "README"
end

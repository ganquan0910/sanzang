require "rdoc/task"

task :default => [:test, :build]

desc "Build RubyGem"
task :build do
  FileUtils.cd(File.dirname(__FILE__))
  Rake.sh "gem build sanzang.gemspec"
  puts ""
  Dir.glob("sanzang*.gem").each do |gem|
    FileUtils.mv(gem, "dist")
    puts("=> #{File.join("dist", gem)}")
  end
end

desc "Clean old build files"
task :clean do
  Dir.glob(File.join(File.dirname(__FILE__), "dist", "*.gem")) do |gem|
    File.delete(gem)
  end
end

desc "Run unit tests"
task :test do
  FileUtils.cd(File.dirname(__FILE__))
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

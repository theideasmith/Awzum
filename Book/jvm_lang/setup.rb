require "fileutils"
include FileUtils

puts "Your Language setup script"
puts "=========================="

print "Enter the desired name of your language (no space, CamelCase, eg.: YourLang): "
NAME = gets.chomp
exit if NAME.empty?
DIRNAME = NAME.downcase

print "Enter the desired extension of a language file, without the dot (eg.: yl): "
EXT = gets.chomp
exit if EXT.empty?

puts "Installing files, this can take a while ..."

def rename(content)
  content.gsub("YourLang", NAME).gsub("yourlang", DIRNAME).gsub(".yl", ".#{EXT}")
end

mv "src/yourlang", "src/#{DIRNAME}"
files = (Dir["*"] + Dir["{bin,src,test}/**/*"].sort_by { |f| f.size } - ["setup.rb"]).select { |f| File.file?(f) }

files.each do |file|
  file_content = rename(File.read(file))
  File.open(file, 'w') { |f| f << file_content }
  mv file, rename(file) unless file == rename(file)
end

puts "Setup complete. Your language '#{NAME}' is ready!"
puts

puts File.read("README")
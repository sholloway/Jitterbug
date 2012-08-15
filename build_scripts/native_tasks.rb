desc "Display the Image I/O formats"
task :image_io_support do
  framework "Quartz"
  puts "Image I/O Input Formats:"
  can_read_from = CGImageSourceCopyTypeIdentifiers()
  CFShow(can_read_from)
  puts " "

  puts "Image I/O Output Formats:"
  can_write_to = CGImageDestinationCopyTypeIdentifiers()
  CFShow(can_write_to)
end

desc "Display the curent OpenGL info"
task :opengl_info do
end

desc "Display the supported OpenGL extensions"
task :list_opengl_extensions do
end
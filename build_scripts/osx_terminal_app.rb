TERM_ARCH 		    = '-arch x86_64'
TERM_FRAMEWORKS 	= "-framework MacRuby -framework Foundation"
TERM_GCFLAGS      = '-fobjc-gc-only'
TERM_COMPILER     = 'clang'

TERM_CONTENTS_DIR 	= "#{TERM_NAME}.app/Contents"
TERM_MAIN           ="osx_terminal_build/main.m"
TERM_RESOURCE_DIR 	= File.join(TERM_CONTENTS_DIR, 'Resources')
TERM_MACOS_DIR 		  = File.join(TERM_CONTENTS_DIR, 'MacOS')
TERM_FRAMEWORKS_DIR	= File.join(TERM_CONTENTS_DIR, 'Frameworks')

COPY_TERMINAL_FILES = FileList["lib/**/*.rb",  
  "vendor/**/*.rb", 
  "resources/images/*.tiff", 
  "resources/images/*.icns", 
  "resources/*.strings",
	"English.lproj/*.strings"]
	
COPY_TERMINAL_FRAMEWORKS = FileList["#{TERM_FRAMEWORK_NAME}.bundle"]

transform_task(:copy_osx_terminal_files, COPY_TERMINAL_FILES, TERM_RESOURCE_DIR) {|target, src| cp_r(src, target)}
transform_task(:copy_osx_terminal_frameworks, COPY_TERMINAL_FRAMEWORKS, TERM_FRAMEWORKS_DIR) {|target, src| cp_r(src, target)}

# Create the Application Bundle and compile the main.m file
file File.join(TERM_MACOS_DIR, TERM_NAME) => [:copy_osx_terminal_files, :copy_osx_terminal_frameworks] do |t|
	mkdir_p("#{TERM_MACOS_DIR}", :verbose => false)	
	sh "#{TERM_COMPILER} #{TERM_MAIN} -L#{TERM_FRAMEWORKS_DIR} -o #{t.name} #{TERM_ARCH} #{TERM_FRAMEWORKS} #{TERM_GCFLAGS}"
end

desc "Creates a terminal application with an application bundle."
task :create_foxtrot => [:create_osx_terminal_framework,
    File.join(TERM_MACOS_DIR, TERM_NAME)]

desc "Run the terminal application that is locally built. It is much better to create an alias in .bash_profile."
task :foxtrot, :arg1, :arg2 do |t, args|
  arguements = "#{args[:arg1]} #{args[:arg2]}"  
  sh "#{TERM_NAME}.app/Contents/MacOS/#{TERM_NAME} #{arguements}"
end
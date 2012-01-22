=begin
desc "Run lldb against foxtrot"
task :lldb => [:deploy_foxtrot] do
  #not really working for me...
  sh "lldb /Users/sholloway/Dropbox/Jitterbug/Foxtrot.app/Contents/MacOS/Foxtrot render"
end
=end

#dtrace shortcuts
desc "Get Method Invocation Count from dTrace"
task :method_count do 
  #need to have this run in a directory that has a sketch to render. Could use jitterbug's -d option
  sh "sudo dtrace -q -F -s dtrace/methods_count.d -c '/Users/sholloway/Dropbox/Jitterbug/Foxtrot.app/Contents/MacOS/Foxtrot render'"
end
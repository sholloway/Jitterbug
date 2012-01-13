=begin
desc "Run lldb against foxtrot"
task :lldb => [:deploy_foxtrot] do
  #not really working for me...
  sh "lldb /Users/sholloway/Dropbox/Jitterbug/Foxtrot.app/Contents/MacOS/Foxtrot render"
end
=end
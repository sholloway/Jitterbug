module Jitterbug
  module Init
    def load_shared_frameworks  
      frameworks_path = NSBundle.mainBundle.privateFrameworksPath.fileSystemRepresentation  
      Dir.glob(File.join(frameworks_path, '*.bundle')).map { |x| File.basename(x, File.extname(x)) }.uniq.each do |path|    
        require(File.join(frameworks_path,path))
      end
    end

    # Loading all the Ruby project files.
    def load_ruby_code
      main = File.basename(__FILE__, File.extname(__FILE__))
      resources_path = NSBundle.mainBundle.resourcePath.fileSystemRepresentation  
      Dir.glob(File.join(resources_path,'**/*.{rb,rbo}')).uniq.each do |path|    
        if path != __FILE__
         require(path)
        end
      end
    end
  end
end




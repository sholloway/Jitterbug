require 'logger'

module Jitterbug
	module Logging
		class JitterLogger
			
			# If -v is passed, then STDOUT should be the source of this logger.
			# Otherwise it should create a log file.
			# The log file should live in sketch/logs. However, what about creating a sketch?
			def initialize(options,name)
				@options = options
				log_file_name = File.expand_path("#{@options[:working_dir]}/#{@options[:logs]}")
				file = open("#{log_file_name}/#{name}", File::WRONLY | File::APPEND | File::CREAT)
				@logger = Logger.new(file)
				@logger.level = Logger::DEBUG
				@logger.datetime_format = "%H:%M:%S" 
				@logger.info("Jitterbug logger initialized")
			end
			
			def debug(msg)
				@logger.debug(msg)
			end
			
			def error(msg)
				@logger.error(msg)
			end
			
			def fatal(msg)
				@logger.fatal(msg)
			end
			
			def info(msg)
				@logger.info(msg)
			end
			
			def warn(msg)
				@logger.warn(msg)
			end
			
			def close
				@logger.close
			end
			
			def debug?
			  @logger.debug?
		  end
		end	
	end
end
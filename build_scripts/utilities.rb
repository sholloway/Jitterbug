# Create a transformation task and associate with taskSymbol for a set of
# input files.	The transformation is passed as a block with target and src
# parameters. The input files can be a file list or a glob search pattern. The
# target directory given will be used and any intermediate directories to
# reach the target will be created.	The target's extension, if different, is
# given otherwise the same extension will be used.
# Original Source: Dave Baldwin's Sketch MacRuby Sample
def transform_task (taskSymbol, fl_or_srcGlob, targetDir, targetExt = nil, &block)
	fileList = fl_or_srcGlob.kind_of?(FileList) ? fl_or_srcGlob : FileList[fl_or_srcGlob]
	fileList.each do |src|
		target = File.join(targetDir, src)
		target = target.ext(targetExt) if targetExt
		file target => [src] do
			mkdir_p(target.pathmap("%d"), :verbose => false)
			block.call(target, src)
		end
		task taskSymbol => target
	end
end

def copy_flat(src,dest,ext='rb')
  Dir["#{src}/**/*.#{ext}"].each{|file| FileUtils.cp file, "#{dest}/#{File.basename(file)}", :verbose => true}                 
end
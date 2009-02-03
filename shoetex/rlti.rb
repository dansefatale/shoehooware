#!/usr/bin/env ruby
class LatexToImage
	attr_accessor :latexpreamble 

	def initialize(texstring, file, folder)
		@texinput = texstring
		@filename = file
		@foldername = folder
		@latexfooter = "\n\\end{displaymath} \n\\end{document}"
		@latexpreamble = "\\documentclass[12pt]{article} \n" +
							"\\pagestyle{empty} \n"
		@begindocument = "\n\\begin{document} \n" +
							"\\begin{displaymath}\n"
	end

	def process
		latex = @latexpreamble + @begindocument + @texinput + @latexfooter

		Dir.mkdir(@foldername) unless File::exists?(@foldername)
		Dir.chdir(@foldername)

		file = File.open(@filename + ".tex", "w+")
		file.puts latex
		file.close

		latexpipe = "echo x | latex " + @filename + ".tex" + ";"	
		dvips = "dvips -f " + @filename + ".dvi > " + @filename + ".ps" + ";"
		processPipe =  " echo quit | gs -q -dNOPAUSE -r150x150 -sOutputFile=- -sDEVICE=pbmraw " + @filename + ".ps | " +
				"convert -trim -transparent white - " + #+ @filename + ".ps " + 
                @filename + ".png;"
		cmd =  "/bin/bash -cl '" + latexpipe + dvips + processPipe + "'" 

		p0 = IO.popen("#{cmd} 2>&1") do |f|
			while line = f.gets do
				debug line
			end
		end
		Dir.chdir("..")
	end
end



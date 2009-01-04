require 'rlti'
require 'ftools'

Shoes.app :title => "Mr.Shoehoo does LaTeX", :width => 520, :height => 430, :resizable => false do
	background  chocolate
	stack do
			stack :margin => 10, :height => 386 do
				@mainback_straight = background "img/Shoehoo_sketch_w500.png"
				@mainback_think =  background "img/Shoehoo_eyes_hidden_sketch_w500.png"
				@mainback_think.hide

				@busy = false
				@ticker = animate(5) do |frame|
					if !@busy
						@mainback_straight.show
						@mainback_think.hide
						@latexinput.show
						@ticker.stop
					else
						@mainback_straight.hide
						@mainback_think.show
						@latexinput.hide
						@disp.remove
					end
				end

	
				@latexinput = stack do

					@tex = edit_line :width => 250
					@texbutton = button "Do it!" 
					@disp = para "Type some Latex code"

					@texbutton.click {
						@busy = true
						@ticker.start
						debug "Will think"
						Thread.new do
							# determine a filename
							debug "Thinking in Thread"
							Dir.chdir("/Users/sevi/programming/ruby/shoes/shoetex/img/textest")
							filebase = "LatexImage1"
							j = 2

							while File.exists?(filebase + ".png") do 
								filebase = "LatexImage" + j.to_s
								j += 1 
							end 
						
							lti = LatexToImage.new(@tex.text ,filebase,"tmpfolder")
							lti.latexpreamble += "\\usepackage{amsmath}"
							tic = Time.now
							lti.process
							toc = Time.now
							debug "process call: " + ((toc - tic).to_f).to_s

							# Cleanup
							File.copy("tmpfolder/" + filebase + ".png", ".")
							File.delete(*Dir["tmpfolder/*"])
							Dir.rmdir("tmpfolder") 

							@latexinput.append do
								@disp = image filebase + ".png" 
								@disp.style(:height => (@disp.full_height * 1.5).ceil)
							end
							@busy = false
							debug "Have thought and leave Thread"
						end
					}

				end

				@latexinput.move(20,75)
				
				
			end

			flow do
					button "Straight!!" do
						@latexinput.show
						@mainback_think.hide
						@mainback_straight.show
					end
			end	
	end
end

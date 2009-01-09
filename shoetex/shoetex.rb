# This is Mr.Shoehoo, the smart eagle owl with Shoes in his first mission -- ShoeTeX.
# Give him some Latex formula and he will notate it in beautiful math notation and show
# it to you. As a gift you can also keep a png image of your formula. Of course Mr.Shoehoo
# needs some tools to work. These are:
# 			- ImageMagick and its commandline tools (he needs 'convert')
#			- Latex of course
#			- Ghostscript
#           - dvips
# Currently Mr.Shoehoo works on OS X Tiger and probably Linux although he hasn't been
# there yet, he also plans to visit windows but before he does that he needs to become
# a bit more self confident.


require 'rlti'
require 'ftools'

Shoes.app :title => "Mr.Shoehoo does LaTeX", :width => 520, :height => 430, :resizable => false do
	background  chocolate
	stack do
			stack :margin => 10, :height => 386 do
				@mainback_straight = background "img/Shoehoo_sketch_w500.png"
				@mainback_think =  background "img/Shoehoo_eyes_hidden_sketch_w500.png"
				@mainback_think.hide
			
	
				@latexinput = stack :top => 75, :left => 20 do

					@tex = edit_line :width => 250
					@texbutton = button "Do it!" 
					@disp = para "Type some Latex code"

					@texbutton.click {
						@ticker.start

						# The @busy variable indicates if the latex thread is running
						@busy = true
						debug "Will think"

						Thread.new do
							debug "Thinking in Thread"
							
							# Create our working directory
							curdir = Dir.pwd
							@img_dir = File.join('', curdir, 'tex_images')
							Dir.mkdir(@img_dir) unless File.exists?(@img_dir)
							Dir.chdir(@img_dir)
							debug Dir.pwd
				
							# Determine a filename
							filebase = "LatexImage1"
							j = 2

							while File.exists?(filebase + ".png") do 
								filebase = "LatexImage" + j.to_s
								j += 1 
							end 
							
							# Fire up our latex processor
							lti = LatexToImage.new(@tex.text ,filebase,"tmpfolder")
							lti.latexpreamble += "\\usepackage{amssymb}"
							tic = Time.now
							lti.process
							toc = Time.now
							debug "process call: " + ((toc - tic).to_f).to_s

							# Cleanup
							File.copy(File.join("tmpfolder", filebase + ".png"), ".")
							File.delete(*Dir["tmpfolder/*"])
							Dir.rmdir("tmpfolder") 
						
							# Take the image we have just created
							# and display it under the input box
							@latexinput.append do
								@disp = stack :width => 250 do
									pic = image filebase + ".png" 	
									if pic.width > 250
										pic.style(:height => (pic.full_height * 1.3).ceil,
													:width => 250)
									end
								end
							end
							
							Dir.chdir(curdir)
							# Tell that we're finished
							@busy = false
							debug "Have thought and leave Thread"
						end
					}

				end

				# the @busy variable indicates if the latex thread is running
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


			end

			# For emergencies
			flow do
					button "Straight!!" do
						@ticker.stop
						@latexinput.show
						@mainback_think.hide
						@mainback_straight.show
					end
			end	
	end
end

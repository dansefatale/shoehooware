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

require '../lib/eye'
require 'rlti'
require 'ftools'

Shoes.app :title => "Mr.Shoehoo does LaTeX", :width => 520, :height => 430, :resizable => false do
	background rgb(85,34,0)
	border black, :strokewidth => 1
	
	# Set a standard dir for the images
	@img_dir = File.join(Dir.pwd, 'tex_images')
	
	@folder_screen = stack :width => 520, :height => 430 do
		fill chocolate
		rect 10, 10, 500, 410, 10
		
		# This one holds the content
		stack :top => 175, :left => 15, :width => 500 do
			para "Were do you want Mr. Shoehoo to put your images?"
			@choose_dir = edit_line :width => 480
			@choose_dir.text = @img_dir

			flow do
				button "Choose..." do
					@choose_dir.text = ask_open_folder	
				end
				
				# Let's slide down
				button "Ok!" do
					@img_dir = @choose_dir.text

					@slider = animate(43) do |i|
						if 430 - 10 * i >= 0
							@folder_screen.move 0, 10 * i
							@main_screen.move 0, -430 + 10 * i
						else
							@slider.stop
						end
					end
				end
			end
		end
	end


	@main_screen = stack :width => 520, :height => 430, :top => -430 do

			fill chocolate
			rect 4, 4, 512, 420, 3
			stack :margin => 10, :height => 386 do
				@mainback_straight = background "img/Shoehoo_w500.png"
				@mainback_think =  background "img/Shoehoo_eyes_hidden_w500.png"
				@mainback_think.hide
			
				# draw the eyes
				@eye_l = eye 349, 78,:eyeball_rad => 22,
								 	 :pupil_rad => 9, 
									 :eyeball_stroke => 6,
									 :pupil_stroke => 9
			
				@eye_r = eye 406, 78,:eyeball_rad => 22,
								 	 :pupil_rad => 9, 
									 :eyeball_stroke => 6,
									 :pupil_stroke => 9

												 

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

				@busy = false

				# The ticker keeps Mr. Shoehoo in thinking
				# position while the latex thread is running
				@ticker = animate(5) do |frame|
					if !@busy
						@mainback_straight.show
						@mainback_think.hide
						@latexinput.show
						@eye_r.show
						@eye_l.show
						@ticker.stop
					else
						@mainback_straight.hide
						@mainback_think.show
						@latexinput.hide
						@eye_r.hide
						@eye_l.hide
						@disp.remove
					end
				end
			end


		flow  :margin_left => 5, :margin_right => 4, :margin_top => 4 do
			background rgb(85,34,0)
			# border black, :strokewidth => 1

			# In case of emergencies
			button "Stop!", :margin_left => 10 do
				@ticker.stop
				@latexinput.show
				@mainback_think.hide
				@mainback_straight.show
			end
				
			# We can also choose a different folder	
			button "Change Folder", :margin_left => 10 do
				@slider = animate(43) do |i|
					if 430 - 10 * i >= 0
						@folder_screen.move 0, 430 - 10 * i
						@main_screen.move 0, -(10 * i)
					else
						@slider.stop
					end
				end
			end
		end	
	end

	#  make the eyes follow you everywhere
	motion do |left,top|
		@eye_l.follow(left,top)
		@eye_r.follow(left,top)
	end

end

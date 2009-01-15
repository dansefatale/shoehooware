# Draw an eye 
#
# Use the follow method to make the eye look into some direction.
# A usage example is at the bottom.


class Eye < Shoes::Widget
	def initialize(left, top,  opts = {}) #fill_col, outer_rad, inner_rad, eye_ball_stroke, pupil_stroke)
		@b = left
		@a = top
		@r = opts[:eyeball_rad] || 50						# The radius of the eye
		@r_p = opts[:pupil_rad] || 20					# The radius of the pupil
		@e_col = opts[:eyeball_col] || yellow			# The color of the eyeball
		@p_col = opts[:pupil_col] || white				# The color of the pupil
		@outer_stroke = opts[:eyeball_stroke] || 3		# Strokewidth for the eyeball
		@inner_stroke = opts[:pupil_stroke] || 18		# Strokewidth for the pupil

		@diff_r = @r_p + @inner_stroke/2
		
		fill @e_col
		strokewidth @outer_stroke
		@ball = oval :center => :true,
					:left => @b,
			 		:top => @a,
					:radius => @r
				
		fill @p_col
		strokewidth @inner_stroke
		@pupil = oval :center => :true, 
						:left => @b,
						:top => @a ,
						:radius => @r_p
	end
	

	# Cause the eye to look towards the point (left,top)
	def follow(left, top)
		if (@a - top)**2 + (@b - left)**2 <= (@r - @diff_r)**2
			l,t = left, top
		else
			dy = left - @b
			dx = top - @a
			rr = Math.sqrt(dx**2 + dy**2)
			l = @b + ((@r - @diff_r)/rr)*dy
			t = @a + ((@r - @diff_r)/rr)*dx 
		end	
		@pupil.move l, t
	end
end


###################### EXAMPLE #######################
#
# Shoes.app :width => 300, :height => 150, :resizable => false do
# 	stack do
# 		@eye1 = eye 75, 75
# 		@eye2 =	eye 225, 75
# 	end
# 	motion do |l,t|
# 		@eye1.follow(l,t)
# 		@eye2.follow(l,t)
# 	end
# end

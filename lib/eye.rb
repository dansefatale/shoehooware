# Draw a eye that follows the cursor

class Eye < Widget
	def initialize( stack, top, left, fill_col, outer_rad, inner_rad, eye_ball_stroke, pupil_stroke)
		@stack = stack
		@stack.app do
			@b = left
			@a = top
			@r = outer_rad
			@r_p = inner_rad
			@outer_stroke = eye_ball_stroke
			@inner_stroke = pupil_stroke
			@diff_r = @r_p + @inner_stroke/2
			@col = fill_col

			fill @col
			strokewidth @outer_stroke
			@ball = oval :center => :true,
						:left => @b,
				 		:top => @a,
						:radius => @r
				
			fill white
			strokewidth @inner_stroke
			@pupil = oval :center => :true, 
							:left => @b,
							:top => @a ,
							:radius => @r_p
		end
	end

	def follow(left, top)
		@stack.app do
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
end



Shoes.app :width => 400, :height => 400 do
	@s = stack
	@t = stack
	stack do
		@eye1 = Eye.new( @s,100, 100, yellow, 50, 20, 3, 18)
		@eye2 =	Eye.new( @t,300, 100, yellow, 50, 20, 3, 18)
	end
		motion do |l,t|
			left = l
			top = t
			@eye1.follow(l,t)
			@eye2.follow(left,top)
		end
end

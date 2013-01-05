#first attempt
#create a single triangle
fill(:red)
triangle(x,y, xx,yy, xxx,yyy)

#create a batch of red triangles
batch_mode(:continuous)
fill(:red)
triangles = []
10.times do |index|
	triangles << [x,y, xx,yy, xxx,yyy]
end
batch(triangles)

#create a batch of triangles all of different colors
batch_mode(:discrete)
triangles = []
10.times do |index|
	triangles << [x,y, xx,yy, xxx,yyy,r,g,b]
end
batch(triangles)

# 2nd attempt
#create a batch of red triangles
fill(:red)
triangles = []
10.times do |index|
	triangles << [x,y, xx,yy, xxx,yyy]
end
batch(type=>:triangles, 
	color=>:continuous, 
	format=>:three_points,
	indices=>:generate  #this would assume that each triangle is stand alone.
	verticies=>triangles)

#3rd attempt
fill(:red)
triangles = []
10.times do |index|
	triangles << [x,y, xx,yy, xxx,yyy]
end
#could be a helper method for batch(:type=>triangles)
triangles(color=>:continuous, 
	format=>:three_points, 
	triangles)

fill(:red)
triangles = [[x,y, xx,yy, xxx,yyy]]
indices = [0,1,2,...]
#could be a helper method for batch(:type=>triangles)
triangles(color=>:continuous, 	
	verticies=>triangles,
	indices=>indices)

fill(:red)
triangles = [[x,y, xx,yy, xxx,yyy, r,g,b,a]]
indices = [0,1,2,...]
#could be a helper method for batch(:type=>triangles)
triangles(:discrete,triangles,indices)

def triangles(color_type, verticies, indices=nil)

end

#problem - Right now, I'm setting a solid color at the vertex
# I can do that because every color is the same. How does the shader know
# what vertex to set the color?

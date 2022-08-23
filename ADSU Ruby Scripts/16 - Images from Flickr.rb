###############################################
#
# Bonus script sample from Alexander C. Schreyer's book
# "Architectural Design with SketchUp"
#
###############################################
#
# This script loads Flickr's RSS feed and exatrcts images from it into the SU model

mod = Sketchup.active_model # Open model
ent = mod.entities # All entities in model
sel = mod.selection # Current selection

tag = 'architecture'  # Flickr search tag
rad = 1000  # circle radius
n = 20  # number of images

# We need a temporary file storage location
user_dir = (defined? Sketchup.temp_dir) ? Sketchup.temp_dir : ENV['TMPDIR'] || ENV['TMP'] || ENV['TEMP']            
f = File.join( user_dir , 'temp.jpg' )

# Use a timer to show length of request
t = Time.now

# Get all recent images in Flickr's RSS feed
URI.open("https://api.flickr.com/services/feeds/photos_public.gne?tags=#{tag}") { |result|
  cnt = result.read
}
p "RSS feed loaded - at #{Time.now - t}s"

# Process feed
collect = URI.extract(cnt, "https")
collect.reject! {|i| !i.include? "_b.jpg" }
# Convert to lower quality before downloading
collect.map {|s| s.gsub!('_b.jpg', '_q.jpg')}

# Insert the images into the model
(0..n-1).each { |i|

    # Load image into temporary file
    URI.open( collect[i] ) do |image|
      File.open( f, "wb" ) do |file|
        file.write( image.read )
      end
    end
    p "Loaded #{uri} - at #{Time.now - t}s"    
    
    # Paste image into model in a circular arrangement
    image = ent.add_image f, [-150,-150,0] , 300
    pos = [Math::sin((i * 360 / n).degrees)*rad, Math::cos((i * 360 / n).degrees)*rad, 0]
    t1 = Geom::Transformation.translation pos
    t2 = Geom::Transformation.new( image.bounds.center, [1,0,0],  90.degrees)
    t3 = Geom::Transformation.new( image.bounds.center, [0,1,0],  -(i * 360 / n).degrees)
    image.transform! t1*t2*t3
    
}

p "Done! - at #{Time.now - t}s"

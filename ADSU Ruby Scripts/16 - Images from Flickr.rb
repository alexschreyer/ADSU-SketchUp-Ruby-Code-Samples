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

require 'net/http'

tag = 'architecture'  # Flickr search tag
rad = 1000  # circle radius
n = 20  # number of images

# Need a temporary file storage location
user_dir = (defined? Sketchup.temp_dir) ? Sketchup.temp_dir : ENV['TMPDIR'] || ENV['TMP'] || ENV['TEMP']            
fn = File.join( user_dir , 'temp.jpg' )

# Use a timer to show length of request
t = Time.now

# Get all images in Flickr's RSS feed
uri = URI("http://api.flickr.com/services/feeds/photos_public.gne?tags=#{tag}")
cnt = Net::HTTP.get(uri)
p "RSS feed loaded - at #{Time.now - t}s"

# Process feed
collect = URI.extract(cnt, "http")
collect.reject! {|i| !i.include? "_b.jpg" }
# Convert to lower quality before downloading
collect.map {|s| s.gsub!('_b.jpg', '_q.jpg')}

# Insert the images into the model
(0..n-1).each { |i|
    uri = URI(collect[i])
    Net::HTTP.start(uri.host) { |http| 
        resp = http.get(uri.path)
        open(fn, 'wb') { |file|
             file.write(resp.body)
        }
    }
    p "Loaded #{uri} - at #{Time.now - t}s"    
    image = ent.add_image fn, [-150,-150,0] , 300
    pos = [Math::sin((i * 360 / n).degrees)*rad, Math::cos((i * 360 / n).degrees)*rad, 0]
    t1 = Geom::Transformation.translation pos
    t2 = Geom::Transformation.new( image.bounds.center, [1,0,0],  90.degrees)
    t3 = Geom::Transformation.new( image.bounds.center, [0,1,0],  -(i * 360 / n).degrees)
    image.transform! t1*t2*t3
}
p "Done! - at #{Time.now - t}s"

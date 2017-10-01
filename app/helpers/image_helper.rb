module ImageHelper 
  def image_details(name)
    base = File.basename(name)
    image = MiniMagick::Image.open("http://localhost:3000" + name)
    #return raw("<br>" + base + "<br><b>" + image.width.to_s + " x " + image.height.to_s + "</b>")
    return raw("<br><b>" + image.width.to_s + " x " + image.height.to_s + "</b>")
  end
end

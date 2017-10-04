module ImageHelper 
  def image_details(name)
    base = File.basename(name)
    image = MiniMagick::Image.open("http://localhost:3000" + name)
    #return raw("<br>" + base + "<br><b>" + image.width.to_s + " x " + image.height.to_s + "</b>")
    return raw("<br><b>" + image.width.to_s + " x " + image.height.to_s + "</b>")
  end

  def generate_image(name, x, y, w)
    #config.logger = Logger.new(STDOUT)
    #logger.debug "generate_image"
    #logger.debug name
    #logger.debug x
    #logger.debug y
    #logger.debug w

    # scaleing x,y to target / display 
    x = (w * x) / 300
    y = (w * y) / 300

    image = MiniMagick::Image.open("http://localhost:3000" + name)
    w_original= image.width.to_f
    h_original= image.height.to_f

    #logger.debug image.width
    #logger.debug image.height

    h = (h_original * w) / w_original

    sw = w + x
    sh = h + y
    geometry = sw.to_i.to_s + "x" + sh.to_i.to_s

    #logger.debug geometry
    image.resize geometry
    #logger.debug image.width
    #logger.debug image.height

    if x != 0 || y != 0
      geometry = w.to_i.to_s + "x" + h.to_i.to_s + "+" + x.to_s + "+" + y.to_s
      image.crop geometry
      #logger.debug geometry
    end

    #logger.debug image.width
    #logger.debug image.height

    dst = mockup_dir + File.basename(name)

    image.write dst

    return dst
  end

  private

  def scale_to_url_thumb(name)
    image = MiniMagick::Image.open(name)
    w_original= image.width.to_f
    h_original= image.height.to_f

    w = 64
    h = (h_original * w) / w_original

    geometry = w.to_s + "x" + h.to_i.to_s
    image.resize geometry

    base = File.basename(name)

    dst = thumb_dir + base
    image.write dst

    url = thumb_url + base
    return url
  end

  def mockup_dir
    dir = "public/mockups/"
    FileUtils.mkdir_p(dir) unless File.directory?(dir)
    return dir
  end

  def thumb_dir
    dir = "public/thumbs/"
    FileUtils.mkdir_p(dir) unless File.directory?(dir)
    return dir
  end

  def thumb_url
    url = "/thumbs/"
    return url
  end

end

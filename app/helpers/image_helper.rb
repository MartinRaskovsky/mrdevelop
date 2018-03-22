module ImageHelper 

  def local_to_url(local)
    init("local_to_url(" + local + ")")
    base = local.sub("public", "")
    http = ENV["LA_CAMISETA_LOCA"]
    if !http
      failed("ENV['LA_CAMISETA_LOCA'] not found")
      http = "https://1ba4f197.ngrok.io"
    end
    url = http + base
    return url
  end

  def scale_to_fit(target, w, h)
    message("scale_to_fit(" + target.to_s + ", " + w.to_s + ", " + h.to_s + ")")
    if w < h
      #    w is a target
      # as h is a h*target/w
      h = (h * target) / w
      w = target
    else                                                                                                 
      w = (w * target) / h
      h = target
    end
    message("scale_to_fit = " + w.to_s + ", " + h.to_s)
    return w, h
  end

  def image_details(name)
    init("image_details(" + name + ")")
    base = File.basename(name)
    image = open_image("public" + name)
    if !image
      return ""
    end
    return raw("<br><b>" + image.width.to_s + " x " + image.height.to_s + "</b>")
  end

  def generate_lowimage(id, name, w, h, pf)
    init("generate_lowimage(" + id.to_s + ", " + name + ", " + w.to_s + ", " + h.to_s + ", " + pf.to_s + ")")
    image = open_image(name)
    if !image
      return ""
    end

    geometry = w.to_i.to_s + "x" + h.to_i.to_s
    message("resize = " + geometry.to_s)
    image.resize geometry
    dst = mockup_dir(_file_unique1(id, name)).sub(".jpg", ".png")

    image.write dst

    return dst
  end

  def generate_image(id, name, x, y, w, h, pf)
    init("generate_image(" + id.to_s + ", " + name + ", " + x.to_s + ", " + y.to_s + ", " + w.to_s + ", " + h.to_s + ", " + pf.to_s + ")")

    dpi = pf['dpi']
    can_rotate = pf['can_rotate']

    image = open_image(name)
    if !image
      return ""
    end

    if can_rotate
      if (w < h and image.width > image.height) or (w > h and image.width < image.height)
        message("rotated")
        #message("Rotating 90d")
        #image.rotate(90)
        t = w
        w = h
        h = t
      end
    end

    w_target = w
    h_target = h

    w_original= image.width.to_f
    h_original= image.height.to_f

    message("image  = " + name)
    message("image  = " + image.width.to_s + "x" + image.height.to_s)

    # and w_original < h_original
    if w_original < h_original #w < h
      # check calculations of x and y
      #x = (w * x) / dpi
      #y = (w * y) / dpi
      h = (h_original * w) / w_original
      message("frame  = " + w.to_i.to_s + "x" + h.to_i.to_s)
      while h < h_target
        w = w + 100
        h = (h_original * w) / w_original
        message("reviewH= " + w.to_i.to_s + "x" + h.to_i.to_s)
      end
    else
      #x = (h * x) / dpi
      #y = (h * y) / dpi
      w = (w_original * h) / h_original
      message("frame  = " + w.to_i.to_s + "x" + h.to_i.to_s)
      while w < w_target
        h = h + 100
        w = (w_original * h) / h_original
        message("reviewW= " + w.to_i.to_s + "x" + h.to_i.to_s)
      end
    end

    sw = w + x
    sh = h + y
    if sw != image.width && sh != image.height
      geometry = sw.to_i.to_s + "x" + sh.to_i.to_s
      message("resize = " + geometry)
      image.resize geometry
    end

    if x != 0 || y != 0
      geometry = w.to_i.to_s + "x" + h.to_i.to_s + "+" + x.to_s + "+" + y.to_s
      message("crop = " + geometry.to_s)
      image.crop geometry
    end

    if w_target != image.width or h_target != image.height
      geometry = w_target.to_s + "x" + h_target.to_s
      message("center = " + geometry)
      cmd = "convert -units PixelsPerInch -size " + geometry + " xc:white -transparent white -density " + dpi.to_s + " tmp.png"
      message(cmd)
      system(cmd) 
      canvas = open_image("tmp.png")
      image = canvas.composite(image) do |c|
        c.compose "Over"
        c.gravity "Center"
      end
    end

    dst = mockup_dir(_file_unique1(id, name)).sub(".jpg", ".png")

    image.write dst

    return dst
  end

  def scale_to_url_thumb(user, name)
    _scale_to_url_thumb(user.id, name)
  end

  def _scale_to_url_thumb(id, name)
    init("scale_to_url_thumb(" + id.to_s + ", " + name + ")")

    image = open_image(name)
    if !image
      return ""
    end
    w_original= image.width.to_f
    h_original= image.height.to_f

    w = 64
    h = (h_original * w) / w_original

    geometry = w.to_s + "x" + h.to_i.to_s

    image.resize geometry

    base = _file_unique1(id, name)     

    dst = thumb_dir(base)
    image.write dst

    url = get_thumb_url + base

    return url
  end

  private

  def init(who)
    @logger = Logger.new(STDOUT)
    @logger.debug who
  end

  def failed(msg)
    #@logger = Logger.new(STDOUT)
    @logger.debug "Failed with " + msg
  end

  def open_image(name)
    begin
      image = MiniMagick::Image.open(name)
      return image
    rescue Errno::ENOENT => e
      failed("Caught the exception: #{e}")
      return nil
    end
  end

  def get_image_dimensions(name)
   image = open_image(name)
    if !image
      return 0, 0
    end
    return image.width, image.height
  end

  def mockup_dir(base)
    name = "public/mockups/" + base
    dir = File.dirname(name)
    FileUtils.mkdir_p(dir) unless File.directory?(dir)
    return name
  end

  def thumb_dir(base)
    name = "public/thumbs/" + base
    dir = File.dirname(name)
    FileUtils.mkdir_p(dir) unless File.directory?(dir)
    return name
  end

  def get_thumb_url
    url = "/thumbs/"
    return url
  end

  def file_unique1(user, name)
    _file_unique1(user.id, name)
  end

  def _file_unique1(id, name)
    name = id.to_s + "/" + Time.now.to_i.to_s + "_" + + File.basename(name)
    name = name.downcase
    return name  
  end

end

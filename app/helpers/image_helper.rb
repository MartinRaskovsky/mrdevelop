module ImageHelper 

  def local_to_url(local)
    init("local_to_url(" + local + ")")
    base = local.sub("public", "")
    http = ENV["LA_CAMISETA_LOCA"]
    if !http
      failed("ENV['LA_CAMISETA_LOCA'] not found")
      http = "https://cdd4f677.ngrok.io"
    end
    url = http + base
    return url
  end

  def image_details(name)
    init("image_details(" + name + ")")
    base = File.basename(name)
    image = open_image("public" + name)
    if !image
      return ""
    end
    #return raw("<br>" + base + "<br><b>" + image.width.to_s + " x " + image.height.to_s + "</b>")
    return raw("<br><b>" + image.width.to_s + " x " + image.height.to_s + "</b>")
  end

  def generate_image(user, name, x, y, w)
    init("generate_image(" + user.id.to_s + ", " + name + ", " + x.to_s + ", " + y.to_s + ", " + w.to_s + ")")

    image = open_image("public" + name)
    if !image
      return ""
    end
    w_original= image.width.to_f
    h_original= image.height.to_f

    # scaleing x,y to target / display 
    if w == 0
      w = image.width
      h = image.height
    else
      x = (w * x) / 300
      y = (w * y) / 300
      h = (h_original * w) / w_original
    end

    sw = w + x
    sh = h + y
    if sw != image.width && sh != image.height
      geometry = sw.to_i.to_s + "x" + sh.to_i.to_s
      image.resize geometry
    end

    if x != 0 || y != 0
      geometry = w.to_i.to_s + "x" + h.to_i.to_s + "+" + x.to_s + "+" + y.to_s
      image.crop geometry
    end

    dst = mockup_dir(file_unique1(user, name))

    image.write dst

    return dst
  end

  def scale_to_url_thumb(user, name)
    init("scale_to_url_thumb(" + user.id.to_s + ", " + name + ")")

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

    base = file_unique1(user, name)     

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
    name = user.id.to_s + "/" + Time.now.to_i.to_s + "_" + + File.basename(name)
    name = name.downcase
    return name  
  end

end

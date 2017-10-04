module FileNameHelper

  def base_image_name(name)
    dir = File.dirname(name)
    base = get_base(name)
    result = dir + "/" + base
    return result
  end

  def large_image_name(name)
    return prefixed_image_name("large", name)
  end

  def medium_image_name(name)
    return prefixed_image_name("medium", name)
  end

  def thumb_image_name(name)
    return prefixed_image_name("thumb", name)
  end

  private

  def get_base(name)
    base = File.basename(name)
    if    base.start_with?("large_")
      base = base[6, base.length]
    elsif base.start_with?("medium_")
      base = base[7, base.length]
    elsif base.start_with?("small_")
      base = base[6, base.length]
    end
    return base
  end

  def prefixed_image_name(prefix, name)
    dir = File.dirname(name)
    base = get_base(name)
    result  = dir + "/" + prefix + "_" + base
    return result
  end


end

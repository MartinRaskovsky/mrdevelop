module FileNameHelper

  def base_image_name(name)
    dir = File.dirname(name)
    base = File.basename(name)
    if base.start_with?("large_")
      base = base[6, base.length]
    end
    result = dir + "/" + base
    return result
  end

  def large_image_name(name)
    dir = File.dirname(name)
    base = File.basename(name)
    result  = dir + "/" + "large_" + base
    return result
  end

end

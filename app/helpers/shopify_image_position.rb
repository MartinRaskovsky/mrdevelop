module ShopifyImagePosition

  def position_images(title, tag, is)

    if tag == "Towel"
      swap(1, is)
  
    elsif title == "Yoga Leggings"
      swap(2, is)
    elsif title == "Capri Leggings"
      swap(7, is)
    elsif title == "Leggings"
      swap(6, is)

    elsif tag == "All-over Shirt"
      swap(2, is)
    end

  end

private

  def swap(i, is)

    if is.length >= i+1
      tmp = is[0]['src']
      is[0]['src'] = is[i]['src']
      is[i]['src'] = tmp
    end

  end

end

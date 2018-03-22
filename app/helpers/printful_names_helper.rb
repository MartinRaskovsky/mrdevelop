module PrintfulNamesHelper

  def get_title(model)
    r = model
    if model == "White Glossy Mug Made in the USA"
      r = "Mug"
    elsif model == "All-Over Cut & Sew Women's Crew Neck"
      r = "Women's T-Shirt"
    elsif model == "All-Over Print Tote"
      r = "Tote Bag"

    elsif model == "All-Over Yoga Leggings"
      r = "Yoga Leggings"
    elsif model == "All-Over Capri Leggings"
      r = "Capri Leggings"
    elsif model == "All-Over Leggings"
      r = "Leggings"

    elsif model == "Rectangular Pillow Case w/ stuffing"
      r = "Pillow"
    elsif model == "iPhone Case"
      r = model
    elsif model == "Sublimation Cut & Sew Dress"
      r = model
    elsif model == "Sublimation Cut & Sew Pencil Skirts"
      r = "Pencil Skirt"
    elsif model == "Sublimation Cut & Sew Mini Skirts" 
      r = "Mini Skirt"
    elsif model == "Sublimated Towel"
      r = "Towel"
    end
    return r
  end
  
  def get_tag(model)
    r = model
    if model == "White Glossy Mug Made in the USA"
      r = "Mug"
    elsif model == "All-Over Cut & Sew Women's Crew Neck"
      r = "All-over Shirt"
    elsif model == "All-Over Print Tote"
      r = "Totes & Bags"

    elsif model == "All-Over Yoga Leggings"
      r = "Leggings"
    elsif model == "All-Over Capri Leggings"
      r = "Leggings"
    elsif model == "All-Over Leggings"
      r = "Leggings"

    elsif model == "Rectangular Pillow Case w/ stuffing"
      r = "Pillow"
    elsif model == "iPhone Case"
      r = "Phone Case"
    elsif model == "Sublimation Cut & Sew Dress"
      r = "Dress"
    elsif model == "Sublimation Cut & Sew Pencil Skirts"
      r = "Skirt"
    elsif model == "Sublimation Cut & Sew Mini Skirts"
      r = "Skirt"
    elsif model == "Sublimated Towel"
      r = "Towel"
    end
    return r
  end

  def is_mcolor(model)
    if model == "All-Over Print Tote"
      return true
    end
    return false
  end

end
 

module PrintfulSizeHelper

  def sort_sizes(vs)
    if vs == ["2XL", "L", "M", "S", "XL", "XS"]
      vs =   ["XS", "S", "M", "L", "XL", "2XL"]
    elsif vs == ["L", "M", "S", "XL", "XS"]
      vs =   ["XS", "S", "M", "L", "XL"]
    end
    return vs
  end

  def size_waist()
    result = "<tr>"
    result << "<td><strong>Waist (inches) </strong></td>"
    result << "<td>25</td>"
    result << "<td>28</td>"
    result << "<td>30</td>"
    result << "<td>35</td>"
    result << "<td>37</td>"
    result << "</tr>"
    return result
  end

  def size_hip
    result = "<tr>"
    result << "<td><strong>Hip (inches) </strong></td>"
    result << "<td>35</td>"
    result << "<td>38</td>"
    result << "<td>41</td>"
    result << "<td>45</td>"
    result << "<td>49</td>"
    result << "</tr>"
    return result
  end

  def size_guide(title, tag, vs)
    result = ""
    is_shirt = tag == "All-over Shirt"
    is_leggings = tag == "Leggings"
    is_dress = tag == "Dress"
    is_skirt = tag == "Skirt"
  
    has_2xl = vs == ["XS", "S", "M", "L", "XL", "2XL"]
  
    if has_2xl or vs == ["XS", "S", "M", "L", "XL"]
      result << "<p><strong>Size guide</strong></p>"
      result << "<div class=\"table-responsive dynamic\" data-unit-system=\"imperial\">"
      result << "<table cellpadding=\"5\">"
      result << "<tbody>"
      result << "<tr>"
      result << "<td>&nbsp;</td>"
      result << "<td><strong>XS</strong></td>"
      result << "<td><strong>S</strong></td>"
      result << "<td><strong>M</strong></td>"
      result << "<td><strong>L</strong></td>"
      result << "<td><strong>XL</strong></td>"
      if has_2xl
        result << "<td><strong>2XL</strong></td>"
      end
      result << "</tr>"
      if is_shirt
        result << "<tr>"
        result << "<td><strong>Chest (inches) </strong></td>"
        result << "<td>31 ¾</td>"
        result << "<td>33 ¾</td>"
        result << "<td>35 ¾</td>"
        result << "<td>37 ¾</td>"
        result << "<td>40 ⅞</td>"
        if has_2xl
          result << "<td>41 ¾</td>"
        end
        result << "</tr>"
        result << "<tr>"
        result << "<td><strong>Length (inches) </strong></td>"
        result << "<td>24 ¾</td>"
        result << "<td>25 ½</td>"
        result << "<td>25 ⅞</td>"
        result << "<td>26 ¼</td>"
        result << "<td>26 ¾</td>"
        if has_2xl
          result << "<td>27 ½</td>"
        end
      elsif is_leggings
        result << size_waist()
        result << "<tr>"
        result << "<td><strong>Hips (inches) </strong></td>"
        result << "<td>35</td>"
        result << "<td>38</td>"
        result << "<td>41</td>"
        result << "<td>45</td>"
        result << "<td>49</td>"
        result << "</tr>"
        result << "<tr>"
        result << "<td><strong>Inseam length (inches) </strong></td>"
        if title == "Yoga Leggings"
          result << "<td>27 ½</td>"
          result << "<td>27 ⅞</td>"
          result << "<td>28 ¼</td>"
          result << "<td>28 ⅞</td>"
          result << "<td>29 ¼</td>"
        elsif title == "Capri Leggings"
          result << "<td>17 ¾</td>"
          result << "<td>18 ½</td>"
          result << "<td>19 ⅝</td>"
          result << "<td>20 ⅜</td>"
          result << "<td>21 ⅝</td>"
        elsif title == "Leggings"
          result << "<td>26 ¼</td>"
          result << "<td>26 ¾</td>"
          result << "<td>27 ⅛</td>"
          result << "<td>27 ½</td>"
          result << "<td>27 ⅞</td>"
        end
      elsif is_dress
        result << "<tr>"
        result << "<td><strong>Bust (inches) </strong></td>"
        result << "<td>32</td>"
        result << "<td>34</td>"
        result << "<td>37</td>"
        result << "<td>42</td>"
        result << "<td>44</td>"
        result << "</tr>"
        result << size_waist()
        result << size_hip()
        result << "<tr>"
        result << "<td><strong>Length (inches) </strong></td>"
        result << "<td>34 ⅜</td>"
        result << "<td>35 ¼</td>"
        result << "<td>36</td>"
        result << "<td>36 ¾</td>"
        result << "<td>37 ½</td>"
      elsif is_skirt
        result << size_waist()
        result << size_hip()
        if title == "Pencil Skirt"
          result << "<tr>"
          result << "<td><strong>Skirt length (inches) </strong></td>"
          result << "<td>19</td>"
          result << "<td>19 ¾</td>"
          result << "<td>21</td>"
          result << "<td>22 ¼</td>"
          result << "<td>23 ⅜</td>"
          result << "</tr>"
        elsif title == "Mini Skirt"
          result << "<tr>"
          result << "<td><strong>Skirt length (inches) </strong></td>"
          result << "<td>14 ½</td>"
          result << "<td>15 ¾</td>"
          result << "<td>16 ⅞</td>"
          result << "<td>18 ⅛</td>"
          result << "<td>19 ⅝</td>"
          result << "</tr>"
        end
      end
      result << "</tr>"
      result << "</tbody>"
      result << "</table>"
      result << "</div>"
    end
    return result
  end

end


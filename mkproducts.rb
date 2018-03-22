#!/bin/ruby                                                                                                                                                                      
require 'shopify_api'
require 'json/pure'
require 'open-uri'
require 'net/http'                                                                                          
require 'uri'
require 'json'
require 'base64'
require 'openssl'
require "mini_magick"

require "./app/helpers/post_helper"
include PostHelper

require "./app/helpers/image_helper"
include ImageHelper

require "./app/helpers/file_name_helper"
include FileNameHelper

require "./app/helpers/printful_helper"
include PrintfulHelper

def init(who)                                                                           
  #puts "init: " + who
end

def failed(why)
  puts "failed: " + why
end

def message(what)
  #puts "message: " + what
end

def html_header()
  puts "<html>"
  puts "<body>"
  puts "<h1>Products</h1>"
  puts "<table>"
end

def html_footer()
  puts "</table>"
  puts "</body>"
  puts "</html>"
end

def td(x)
  if x
    puts "<td valign=top>" + x + "</td>"
  else
    td(" ")
  end
end

def td2(x)
  if x
    puts "<td valign=top colspan=2>" + x + "</td>"
  else
    td2(" ")
  end
end

def tdlab(lab,x)
  td(lab)
  td(x)
end

def img(x)
  td("<img src=\""  + x + "\"</img>")
end

def thumb(x)
  if x
    td("<img width=60 src=\""  + x + "\"</img>")
  end
end

def href(x)
  td("<a href=\""  + x + "\">" + x + "</a>")
end

def href2(x)
  td2("<a href=\""  + x + "\">" + x + "</a>")
end

def get_options(variants)
  size = []
  color = []
  variants.each do |variant|
    size << variant['size'] if variant['size']
    if variant['color']
      if color.length==0 or variant['color'] != color[0]
        color <<  variant['color']
      end
    end
  end
  result = []
  if size.length > 1
    option = { "name" => "Size", "values" => size }
    result << option
  end
  if color.length > 1
    option = { "name" => "Colour", "values" => color }
    result << option
  end
  return result
end

def process(product_id)
  product, variants = get_printful_variants(product_id)
  tag    = get_tag  (product['model'])
  mcolor = is_mcolor(product['model'])

  items, printfile_ids = get_printfile_items(product_id, variants) 
  printfiles           = items['printfiles']

  options = get_options(variants)

  puts "<tr>"
  img(product['image'])

  puts "<td><table border=1 width=\"100%\" bgcolor=\"CCFFCC\">"
    puts "<tr>"
    href2("http://api.printful.com/products/" + product_id)
    puts("</tr><tr>")
    href2("http://api.printful.com/mockup-generator/printfiles/" + product_id)
    puts("</tr><tr>")
    href2("https://api.printful.com/sync/products/" + product_id)
    puts("</tr><tr>")
    tdlab("Id", product['id'].to_s)
    puts("</tr><tr>")
    tdlab("Type", product['type'])
    puts("</tr><tr>")
    tdlab("Brand", product['brand'])
    puts("</tr><tr>")
    tdlab("Model", product['model'])
    puts "</tr>"

    if options.length > 0
      puts "<tr><td colspan=2><table border=1 width=\"100%\" bgcolor=\"CCCCFF\"><tr><td colspan=2>Options</td></tr>"
      options.each do |option|
        puts "<tr>"
        td(option['name'])
        td(option['values'].to_s)
        puts "</tr>"
      end
      puts "</table></td></tr>"
    end

    puts "<tr><td colspan=2><table border=1 width=\"100%\" bgcolor=\"FFCCCC\"><tr><td colspan=6>Print Files</tr><tr><td>Id</td><td>Width</td><td>Height</td><td>DPI</td><td>Fill Mode</td><td>Can Rotate</td></tr>"
    printfile_ids.each do |id|
      puts "<tr>"
      pf = find_printfile(printfiles, id)
      td(pf['printfile_id'].to_s)
      td(pf['width'].to_s)
      td(pf['height'].to_s)
      td(pf['dpi'].to_s)
      td(pf['fill_mode'])
      td(pf['can_rotate'].to_s)
      puts "</tr>"
    end
    puts "</table></td></tr>"

    if mcolor
      fcolor = ""
    else
      fcolor = " for first color"
    end
    puts "<tr><td colspan=2><table border=1 width=\"100%\" bgcolor=\"CCCCFF\"><tr><td colspan=4>Variants" + fcolor + "</td></tr><tr><td>Id</td><td>Size</td><td>Color</td><td>Printfile Ids</td></tr>"
    variants.each do |variant|
      puts "<tr>"
      td(variant['id'].to_s)
      size = variant['size']
      if size
        size = size.sub("×", "x")
        td(size)
      else
        td("")
      end
      if variant['color']
        td(variant['color'])
      else
        td("")
      end
      items, printfile_ids = get_printfile_items(product_id, [ variant ])
      td(printfile_ids.to_s)
      variant.each do |key, value|
        if !(key=='id' \
		or key=='product_id' \
		or key=='name' \
		or key=='color_code' \
		or key=='image' \
		or key=='price' \
		or key=='in_stock' \
		or key=='size' \
		or key=='color' \
              )
          td(key + "=" + value.to_s)
        end
      end
      thumb(variant['image'])
      puts "</tr>"
    end
    puts "</table></td></tr>"
  puts "</table>"
  puts "</td></tr>"
end

def main()

  html_header()
  ARGV.each do|id|
    process(id)
  end
  html_footer()

end

main()


#!/bin/ruby                                                                                                                                                                      
#require 'shopify_api'
#require 'json/pure'
#require 'open-uri'
#require 'net/http'                                                                                          
#require 'uri'
#require 'json'
#require 'base64'
#require 'openssl'

require "./app/helpers/post_helper"
include PostHelper

require "mini_magick"
require "./app/helpers/image_helper"
include ImageHelper

#require "./app/helpers/file_name_helper"
#include FileNameHelper

require "./app/helpers/printful_helper"
include PrintfulHelper

LA_CAMISETA_LOCA="https://bf991e31.ngrok.io"
PRINTFUL_KEY="my7lpmh7-rjv2-dllg:7gh8-awd6jpazrhqf"

def init(who)                                                                           
  #puts "init: " + who
end

def failed(why)
  puts "failed: " + why
end

def message(what)
  #puts "message: " + what
end

def main()
  ENV['LA_CAMISETA_LOCA'] = LA_CAMISETA_LOCA
  ENV['PRINTFUL_KEY']     = PRINTFUL_KEY

  image = ARGV[0]
  set = Set.new([])
  prs = []
  for i in 1..ARGV.length-1
    set, presult = add_printfiles(set, ARGV[i])
    presult.each do |pr|
      prs << pr
    end
  end

  generate_printfiles(image, set)

  result = []
  for i in 1..ARGV.length-1
    pfs = make_printfiles(set, prs, ARGV[i])
    pfs.each do |pf|
      result << pf
    end
  end
 
  puts result.to_json 
end

main()


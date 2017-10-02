require 'net/http'
require 'uri'
require 'json'

module PostHelper

  def post_json(uri, text)
    config.logger = Logger.new(STDOUT)
    logger.debug "post_json"
    logger.debug uri
    logger.debug text

    uri = URI.parse("http://localhost:3000/post")

    header = {'Content-Type': 'text/json'}

    # Create the HTTP objects
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body = text.to_json

    # Send the request
    #response = http.request(request)
    response = true

    return response
  end

  def post_mockup(product_id, variant_list, image_url)
    config.logger = Logger.new(STDOUT)
    logger.debug "post_mockup"
    logger.debug product_id
    logger.debug  variant_list.to_s
    logger.debug image_url

    uri = "https://api.printful.com/mockup-generator/generate/" + product_id
    text = ""
    text << "{"
    text << "    variant_ids : [" + variant_list.to_s + "],"
    text << "    format: 'jpg',"
    text << "    files : ["
    text << "        {"
    text << "            placement: 'front',"
    text << "            image_url: '" + image_url + "'"
    text << "        },"
    text << "        {"
    text << "            placement: 'back',"
    text << "            image_url: '" + image_url + "'"
    text << "        },"
    text << "    ],"
    text << "}"

    response = post_json(uri, text)

    # response
    #{
    #  task_key: "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
    #  status: "pending"
    #}

    # after a few secs do a GET on
    #https://api.printful.com/mockup-generator/task?task_key=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxa

    #At this point, you just have to download the mockup URLs and store them on your own server and you're good to go!
  end    
end

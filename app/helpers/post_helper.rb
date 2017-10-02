require 'net/http'
require 'uri'
require 'json'

module PostHelper

  def post_json(url, text, auth_key)
    config.logger = Logger.new(STDOUT)
    logger.debug "post_json"
    logger.debug url
    logger.debug text

    url = "http://localhost:3000/post"
    uri = URI.parse(url)

    header = {'Content-Type': 'text/json'}

    # Create the HTTP objects
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true     

    request = Net::HTTP::Post.new(uri.request_uri, header)
    request['authorization'] = auth_key if auth_key
    request.body = text.to_json

    # Send the request
    #response = http.request(request)
    #response = http.start {|http| http.request(request) }

    #simulate
    content = '{ "code": 200, "result": [{ "task_key": 123, "status": "pending" }]}'

    config.logger = Logger.new(STDOUT)

    response  = JSON.parse content
    code = response['code']
    if code == 200
      return response['result']
    else
      logger.debug response['code'] if response['code']
      logger.debug "Failed to POST to: " + url
      return nil
    end
  end

  def post_mockup(product_id, variant_list, image_url)
    config.logger = Logger.new(STDOUT)
    logger.debug "post_mockup"
    logger.debug product_id
    logger.debug  variant_list.to_s
    logger.debug image_url

    url = "https://api.printful.com/mockup-generator/generate/" + product_id
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

    response = post_json(url, text, ENV['PRINTFUL_KEY'])
    config.logger = Logger.new(STDOUT)

    if response
      task_key = response[0]['task_key']
      status = response[0]['status']
      if status == "pending"
        logger.debug "OK got pending"
      else
       logger.debug "Unexpected status: " + status
       return nil
      end
    else
      logger.debug "Failed to post mockup"
      return nil
    end

    # after a few secs do a GET on
    #https://api.printful.com/mockup-generator/task?task_key=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxa

    #At this point, you just have to download the mockup URLs and store them on your own server and you're good to go!
  end

end

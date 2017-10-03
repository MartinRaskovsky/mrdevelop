require 'net/http'
require 'uri'
require 'json'

module PostHelper

  def get_product(product_id)                                                                                              
    init("get_product")
    logger.debug product_id

    url = "http://api.printful.com/products/" + product_id

    result = http_get(url, nil)

    return validate_product(result, product_id)
  end

  def get_variants(product_id)
    init("get_variants")
    logger.debug product_id

    url = "https://api.printful.com/products/" + product_id

    result = http_get(url, nil)

    if !validate_product(result, product_id)
      return nil
    end

    variants = result['variants']
    if !variants
      logger.debug "Failed to get variants from GET"
      return nil
    end

    return variants
  end

  def get_printfile_details(product_id)
    init("get_printfile_details")
    logger.debug product_id

    url = "http://api.printful.com/mockup-generator/printfiles/" + product_id
    result = http_get(url, ENV["PRINTFUL_KEY"])

    if !validate_product_id(result, product_id)
      return nil
    end
    
    return result
  end

  def post_mockup(product_id, details)
    init("post_mockup")
    logger.debug product_id
    logger.debug  details.to_s

    url = "https://api.printful.com/mockup-generator/generate/" + product_id

    # TEMPORARY process each request sequentially
    details.each do |detail|
      text = ''
      text << '{'
      text << '    "variant_ids" : ' + detail['variants'].to_s + ','
      text << '    "format": "jpg",'
      text << '    "files" : ['
      detail['placements'].each.with_index do |placement, i|
        text << '    { '
        text << '      "placement": "' + placement[0] + '",'
        text << '      "image_url": "' + "FIX IMG" + '"'
        if i < detail['placements'].length-1
          text << '    },'
        else
          text << '    }'
        end
      end
      text << '  ]'
      text << '}'
  
      response = post_json(url, text, ENV["PRINTFUL_KEY"])
      if !response
        return nil
      end

      task_key = response[0]['task_key']
      status = response[0]['status']
      if status == "pending"
        logger.debug "OK got pending"
      else
        logger.debug "Unexpected status: " + status
        return nil
      end

      # after a few secs do a GET on
      #https://api.printful.com/mockup-generator/task?task_key=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxa
  
      #At this point, you just have to download the mockup URLs and store them on your own server and you're good to go!
    end
  end

  private

  def init(who)
    config.logger = Logger.new(STDOUT)
    logger.debug who
  end

  def validate_content(content)
    case content
    when Net::HTTPSuccess then
      puts "Success"
    when Net::HTTPNoContent then
      puts "No Content"
      return nil
    when Net::HTTPBadRequest then
      puts "Bad Request"
      return nil
    when Net::HTTPUnauthorized then
      puts "Unauthorized"
      return nil
    when Net::HTTPRedirection then
      location = content['location']
      puts "redirected to #{location}"
      #fetch(location, limit - 1)
      return nil
    end

    if !content.body
      logger.debug "Failed to GET content"
    end

    #logger.debug content.body
    return content.body
  end

  def validate_result(content)
    response  = JSON.parse content
    code = response['code']
    if code != 200
      logger.debug response['result'] if response['result']
      logger.debug "code=" + code.to_s if code
      return nil
    end

    result = response['result']
    if result == nil
      logger.debug "Failed to GET result"
    end

    return result
  end

  def validate_product(result, id)
    if !result
      logger.debug "Failed to get result from GET"
      return nil
    end

    product = result['product']
    if !product
      logger.debug "Failed to get product from GET"
      return nil
    end

    if !product['id']
      logger.debug "Failed to get product id from GET"
      return nil
    end

    if product['id'] != id.to_i
      logger.debug "Failed to get product id: " + id + " from GET, got: " + product['id'].to_s + " instead"
      return nil
    end

    return product
  end

  def validate_product_id(result, id)                                                                                          
    if !result
      logger.debug "Failed to get result from GET"
      return nil
    end

    product_id = result['product_id']

    if !product_id
      logger.debug "Failed to get product id from GET"
      return nil
    end

    if product_id != id.to_i
      logger.debug "Failed to get product id: " + id + " from GET, got: " + product_id.to_s + " instead"
      return nil
    end

    return product_id
  end

  def http_get(url, auth_key)
    logger.debug "http_get"
    logger.debug url
    logger.debug auth_key if auth_key

    uri = URI.parse(url)

    # Create the HTTP objects
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = url.start_with?("https://")

    request = Net::HTTP::Get.new(uri)
    request['Authorization'] = "Basic " + Base64::encode64(auth_key) if auth_key
    request.body = ""

    # Send the request
    content = http.request(request)
    content = validate_content(content)

    if !content
      return nil
    end

    return  validate_result(content)
  end

  def post_json(url, text, auth_key)
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

    if false
      # Send the request
      content = http.request(request)
      content = http.start {|http| http.request(request) }
      content = validate_content(content)
    else
      #simulate
      content = '{ "code": 200, "result": [{ "task_key": 123, "status": "pending" }]}'
    end

    if !content
      return nil
    end

    return validate_result(content)
  end

end

require 'net/http'
require 'uri'
require 'json'
require 'base64'
require 'openssl'

module PostHelper

  def put_img(img_file, index)
    init("put_img(" + img_file + ", " + index.to_s + ")")

    dst_host = "http://martinR.com"
    dst_base = file_unique2(index, img_file)
    dst_url = dst_host + "/mockups/" + dst_base
    url = dst_host + "/cgi-bin/mockups.cgi"
    #logger.debug url

    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    #http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    boundary = "AaB03x"
    #header = {"Content-Type": "multipart/form-data; boundary=#{boundary}"}

    post_body = []

    # Add the file Data
    file = open(img_file)
    post_body << "--#{boundary}\r\n\r\n"
    post_body << "Content-Disposition: form-data; name=\"file\"; filename=\"#{File.basename(img_file)}\"\r\n"
    post_body << "Content-Type: text/plain\r\n"
    post_body << "\r\n"
    post_body << Base64.encode64(file.read)
    file.close

    # Add the name
    post_body << "\r\n--#{boundary}\r\n"
    post_body << "Content-Disposition: form-data; name=\"name\"\r\n\r\n"
    post_body << dst_base
    post_body << "\r\n--#{boundary}--\r\n"

    request = Net::HTTP::Post.new(uri.request_uri)
    request["Content-Type"] = "multipart/form-data; boundary=#{boundary}"
    #request.set_form_data({'name' => '"' + dst_base +'"'}, ';')
  
    request.body = post_body.join
 
    response = safe_request(http, request)

    if !response
      return nil
    end

    #logger.debug response.code
    #logger.debug response.body

    logger.debug "put_img=" + dst_url
    return dst_url
  end

  def get_product(product_id)
    init("get_product(" + product_id + ")")

    url = "http://api.printful.com/products/" + product_id

    result = http_get(url, nil)

    return validate_product(result, product_id)
  end

  def get_variants(product_id)
    init("get_variants(" + product_id + ")")

    url = "https://api.printful.com/products/" + product_id

    result = http_get(url, nil)

    product = validate_product(result, product_id)
    if !product
      return [nil, nil]
    end

    variants = result['variants']
    if !variants
      logger.debug "Failed to get variants from GET"
      return [product, nil]
    end

    return [product, variants]
  end

  def get_printfile_details(product_id)
    init("get_printfile_details(" + product_id + ")")

    url = "http://api.printful.com/mockup-generator/printfiles/" + product_id
    result = http_get(url, ENV["PRINTFUL_KEY"])

    if !validate_product_id(result, product_id)
      return nil
    end
    
    return result
  end

  def post_mockup(product_id, details)
    init("post_mockup(" + product_id + ", " + details.to_s + ")")

    url = "https://api.printful.com/mockup-generator/create-task/" + product_id

    # TEMPORARY process each request sequentially
    details.each do |detail|
      text = []
      text << '{'
      text << '    "variant_ids": ' + detail['variants'].to_s + ','
      text << '    "format":"jpg",'
      text << '    "files":['
      done = false
      detail['placements'].each.with_index do |placement, i|
        if !placement[0].start_with?("label")
          if done
            text << ','
          end
          done = true
          text << '    {'
          text << '      "placement": "' + placement[0] + '",'
          text << '      "image_url": "' + detail['printfile']["image_url"]  + '"'
          text << '    }'
        end
      end
      text << '  ]'
      text << '}'

      result = post_json(url, text.join, ENV["EPRINTFUL_KEY"])
      if !result
        return nil
      end

      task_key = result['task_key']
      status = result['status']
      if status != "pending"
        logger.debug "Unexpected status: " + status
        return nil
      end

      url = "http://api.printful.com/mockup-generator/task?task_key=" + task_key.to_s

      while status == "pending"
        logger.debug "Sleeping 3 sec ..."
        sleep(3);
        result = http_get(url, ENV["PRINTFUL_KEY"])
        if result
          status = result['status']
        else
          logger.debug "Failed to GET, trying again"
        end
      end

      if status != "completed"
        logger.debug "Unexpected status " + status
        return nil
      end
      
      mockups = result['mockups'] 
      if mockups == nil
        logger.debug "Failed to GET mockups"
      end

      return mockups
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
      puts ""
      puts content.read_body
      puts "Bad Request"
      puts ""
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
    if auth_key
      init("http_get(" + url + ", " + auth_key + ")")
    else
      init("http_get(" + url + ")")
    end

    uri = URI.parse(url)

    # Create the HTTP objects
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')

    request = Net::HTTP::Get.new(uri)
    request['Authorization'] = "Basic " + Base64::encode64(auth_key) if auth_key
    request.body = ""

    # Send the request
    content = safe_request(http, request)
    content = validate_content(content)

    if !content
      return nil
    end

    return  validate_result(content)
  end

  def post_json(url, text, auth_key)
    if auth_key
      init("post_json(" + url + ", " + text + ", " + auth_key + ")")
    else
      init("post_json(" + url + ", " + text + ")")
    end

    uri = URI.parse(url)

    # Create the HTTP objects
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new(uri)
    request["content-type"] = 'application/json'
    request["authorization"] = "Basic " + auth_key
    request.body = text

    # Send the request
    content = safe_request(http, request)
    content = validate_content(content)

    if !content
      return nil
    end

    return validate_result(content)
  end

  def file_unique2(index, name)
    name = current_user.id.to_s + "/" + Time.now.to_i.to_s + "_" + index.to_s + "_" + File.basename(name)
    name = name.downcase
    return name
  end

  def safe_request(http, request)
    openuri_params = {
      # set timeout durations for HTTP connection
      # default values for open_timeout and read_timeout is 60 seconds
      :open_timeout => 1,
      :read_timeout => 1,
    }

    attempt_count = 0
    max_attempts  = 3

    begin
      attempt_count += 1
      if attempt_count > 1
        logger.debug "attempt ##{attempt_count}"
      end
      response = http.request(request)
    rescue OpenURI::HTTPError => e
      # it's 404, etc. (do nothing)
    rescue SocketError, Net::ReadTimeout => e
      # server can't be reached or doesn't send any respones
      logger.debug "error: #{e}"
      sleep 3
      retry if attempt_count < max_attempts
    end

    return response
  end

end

#require 'sinatra'
require 'json'

class NotesController < ApplicationController
#class HomeController < ShopifyApp::AuthenticatedController
skip_before_action :verify_authenticity_token

  def check(who)
    config.logger = Logger.new(STDOUT)
    logger.debug "NotesController: " + who

    verify_webhook(request)

    request.body.rewind
    request_payload = JSON.parse request.body.read

    logger.debug "check: " + request_payload.to_json
    return request_payload
  end

  def ordercreation
    content = check("ordercreation")

    mockup_id = get_id(content)
    mockup = get_mockup(mockup_id)

    head :ok
  end

  def checkoutcreation
    content = check("checkoutcreation")

    mockup_id = get_id(content)
    mockup = get_mockup(mockup_id)
 
    head :ok
  end


  private

  def verify_webhook(request)
    header_hmac = request.headers["HTTP_X_SHOPIFY_HMAC_SHA256"]
    digest = OpenSSL::Digest.new("sha256")
    request.body.rewind
    calculated_hmac = Base64.encode64(OpenSSL::HMAC.digest(digest, ENV['HTTP_X_SHOPIFY_HMAC_SHA256'], request.body.read)).strip

    ok = ActiveSupport::SecurityUtils.secure_compare(calculated_hmac, header_hmac)

    puts "Verified:#{ok}"
  end

  def get_id(content)
    if !content
      return nil
    end

    note = content['note']
    if !note
      return nil
    end

    logger.debug "note=\"" + note + "\""
    mockup_id = note.sub("REF ", "").to_i

    if !mockup_id
      return nil
    end

    logger.debug "mockup_id=" + mockup_id.to_s
    return mockup_id
  end

  def get_mockup(mockup_id)
    if !mockup_id
      return nil
    end

    mockup = Mockup.find(mockup_id)

    if !mockup
      return nil
    end

    logger.debug "MOCKUP: " + mockup.to_json
    return mockup
  end

end


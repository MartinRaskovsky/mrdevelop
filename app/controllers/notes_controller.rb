#require 'sinatra'
require 'json'
 
class NotesController < ApplicationController
skip_before_action :verify_authenticity_token

  def check(who)
    config.logger = Logger.new(STDOUT)
    logger.debug "NotesController: " + who

    verify_webhook(request)

    request.body.rewind
    request_payload = JSON.parse request.body.read

    logger.debug request_payload.to_json
    return request_payload
  end

  def ordercreation
    contents = check("ordercreation")

    
    head :ok
  end

  def checkoutcreation
    check("checkoutcreation")
    head :ok
  end

  private

  def verify_webhook(request)
    header_hmac = request.headers["HTTP_X_SHOPIFY_HMAC_SHA256"]
    digest = OpenSSL::Digest.new("sha256")
    request.body.rewind
    calculated_hmac = Base64.encode64(OpenSSL::HMAC.digest(digest, ENV['HTTP_X_SHOPIFY_HMAC_SHA256'], request.body.read)).strip

    #puts "header hmac: #{header_hmac}"
    #puts "calculated hmac: #{calculated_hmac}"

    ok = ActiveSupport::SecurityUtils.secure_compare(calculated_hmac, header_hmac)

    puts "Verified:#{ok}"
  end

end

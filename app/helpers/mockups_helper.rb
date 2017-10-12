module MockupsHelper

  def run_mockup(is_mockup, params)
    config.logger = Logger.new(STDOUT)

    product_id = params[:id]
    image_id = params['image_id']
    params['product_id'] = product_id

    product = get_product(product_id)

    mockup = Mockup.new({
      :product_url => product['image'],
      :image_url   => image_thumb(image_id), 
      :thumb_url   => nil,
      :mockup_url  => nil,
      :printful_id => product_id.to_i,
      :shopify_id  => 0,
      :job_id      => 0,
      :cart        => nil
    })
  
    if !mockup.save                                                                                       
      logger.debug "Failed to save mockup"
      return false
    end

    job = Delayed::Job.enqueue MockupJob.new(current_user, params, mockup, is_mockup)
    
    mockup.update({:job_id => job.id})

    return true
 
  end
end

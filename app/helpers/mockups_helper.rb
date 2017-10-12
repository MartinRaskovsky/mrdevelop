module MockupsHelper

  def run_mockup(params)
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

    job = Delayed::Job.enqueue MockupJob.new(current_user, params, mockup)
    
    mockup.update({:job_id => job.id})

    return true
 
  end

  def make_printfiles(params)
    config.logger = Logger.new(STDOUT)

    product_id = params[:id]
    image_id = params['image_id']
    params['product_id'] = product_id

    product = get_product(product_id)

    printfile = Printfile.new({
      :printfile_url  => nil,
      :printful_id => product_id.to_i,
      :shopify_id  => 0,
      :job_id      => 0
    })

    if !printfile.save
      logger.debug "Failed to save printfile"
      return false
    end

    job = Delayed::Job.enqueue PrintfileJob.new(current_user, params, printfile)
    
    printfile.update({:job_id => job.id})

    return true
  end

end

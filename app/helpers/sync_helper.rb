module SyncHelper

  def sync_shopify_printful(product_id, pfs, pr, variants, map)
    variants.each do |variant|
      variant_id = variant['id']
      text = find_printfiles_to_sync(pfs, product_id, variant_id)
      if text
        position = variant[:position]
        shopify_variant_id = map[position]
        maxtries = 20
        numtries = 0
        found = false
        while !found and numtries < maxtries
          if find_sync_variant(product_id, shopify_variant_id)
            found = true
            break
          end
          numtries = numtries + 1
          puts "Waiting 10 secs (" + numtries.to_s + "/" + maxtries.to_s + ") for variant " + variant_id.to_s + " to materialize"
          sleep(10)
        end

        ok = false
        if found
          ok = post_sync(shopify_variant_id, text)
        end
        if !found or !ok
          puts "Sync abandoned, save this:"
          puts "shopify_variant_id=" + shopify_variant_id.to_s
          puts "args=" + text.join.to_json
        end
     end
    end

  end

  private

  def find_printfiles_to_sync(pfs, product_id, variant_id)
    init("find_printfiles_to_sync(" + product_id.to_s + ", " + variant_id.to_s + + ")")
    text = []                                                                                                       
    text << '{'
    text << '    "variant_id": ' + variant_id.to_s + ','
    text << '    "files":['
    done = false
    pfs.each do |pf|
      if product_id == pf['product_id'] and variant_id == pf['variant_id']
        if done
          text << ',' 
        end
        done = true
        text << '    {'
        if pf['type'] != "default"
          text << '      "type": "' + pf['file_type'] + '",'
        end
        text << '      "url": "' + pf['url'] + '"'
        text << '    }'
      end
    end
    text << '  ],'
    text << '  "options": []'
    text << '}'

    if !done
      failed("Failed to find pf for " + product_id.to_s + "x" + variant_id.to_s + " in " + pfs.to_json)
      return nil
    end

   puts "find_printfiles_to_sync=" + text.join.to_json

   return text
  end

end


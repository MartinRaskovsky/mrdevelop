diff --git a/app/controllers/images_controller.rb b/app/controllers/images_controller.rb
index 9f191b1..3f634cd 100644
--- a/app/controllers/images_controller.rb
+++ b/app/controllers/images_controller.rb
@@ -24,8 +24,7 @@ class ImagesController < ApplicationController
    elsif commit == "Upload Image"
       upload_image
    elsif commit == "Generate Mockup"
-     Delayed::Job.enqueue ImagesJobController.new(current_user, params)
-     redirect_to mockups_path, notice: "Mockup cresation is in the background."
+      make_mockup
    else
       url = { :controller => 'product', :action => 'index', :id => params["product_id"] }
       redirect_to url
@@ -77,6 +76,13 @@ class ImagesController < ApplicationController
     return false
   end
 
+  def has_design
+    if params.has_key?(:image_id)
+      return true
+    end
+    return false
+  end
+
   def make_design
     if has_select_image
       image = params['image']
@@ -100,4 +106,33 @@ class ImagesController < ApplicationController
     end
   end
 
+  def make_mockup
+    if !has_design 
+      redirect_to :controller => 'product', :action => 'index', :id => params["product_id"]
+      return
+    end
+
+    product = get_product(params['product_id'])
+    @mockup = Mockup.new({
+      :product_url => product['image'],
+      :image_url   => image_thumb(params['image_id']), 
+      :thumb_url   => nil,
+      :mockup_url  => nil,
+      :printful_id => params['product_id'].to_i,
+      :shopify_id  => 0
+    })
+    if !@mockup.save                                                                                       
+      logger.debug "Failed to save mockup"
+      redirect_to :controller => 'product', :action => 'index', :id => params["product_id"], :image_id => params[:image_id]
+      return
+    end
+
+    Delayed::Job.enqueue ImagesJobController.new(current_user, params, @mockup)
+    redirect_to mockups_path, notice: "Mockup cresation is in the background."
+  end
+
+  def image_thumb(large_url)                                                                                          
+    return thumb_image_name(large_url)
+  end
+
 end
diff --git a/app/controllers/images_job_controller.rb b/app/controllers/images_job_controller.rb
index 15b3a6b..985186c 100644
--- a/app/controllers/images_job_controller.rb
+++ b/app/controllers/images_job_controller.rb
@@ -2,36 +2,23 @@ include FileNameHelper
 include ImageHelper
 include PostHelper
 
-class ImagesJobController < Struct.new(:user, :params)
+class ImagesJobController < Struct.new(:user, :params, :mockup)
+
   def perform
     self.params = params
+    @mockup = mockup
     logger = Logger.new(STDOUT)
     generate_mockup(user)
   end
 
-  def run
-    perform
-  end
-
   private
  
-  def has_design
-    if params.has_key?(:image_id)
-      return true
-    end
-    return false
-  end
-
   def generate_mockup(user)
-    if !has_design
-      #redirect_to :controller => 'product', :action => 'index', :id => params["product_id"]
-      return
-    end
-
     product_id = params['product_id']
     x = params['xpos_field'].to_i
     y = params['ypos_field'].to_i
     w = 1000
+    mockup_url = nil
 
     vars = printfile_variants(product_id)
     details = printfile_details(product_id, vars)
@@ -58,20 +45,6 @@ class ImagesJobController < Struct.new(:user, :params)
       return
     end
 
-    @mockup = Mockup.new({
-      :mockup_url  => nil,
-      :thumb_url   => generate_thumb(user, mockups[0]['mockup_url']),
-      :product_url => product_thumb(user, params['product_id']),
-      :image_url   => image_thumb(params['image_id']),
-      :printful_id => params['product_id'].to_i,
-      :shopify_id  => 0
-    })
-    if !@mockup.save                                                                                       
-      logger.debug "Failed to save mockup"
-      #redirect_to :controller => 'product', :action => 'index', :id => params["product_id"], :image_id => params[:image_id]
-      return
-    end
-
     mockups.each do |mockup|
 
       main_image = mockup['mockup_url'] #put_img(user, mockup['mockup_url'], 0)
@@ -117,11 +90,20 @@ class ImagesJobController < Struct.new(:user, :params)
         #redirect_to :controller => '/mockups'
         return
       end
-      if @mockup['mockup_url'] == nil
-        mockup.update(mockup_url: main_image)
+      if mockup_url == nil
+        mockup_url = main_image
       end
     end
 
+    @mockup.update({
+      #:product_url => product_thumb(user, params['product_id']),
+      #:image_url   => image_thumb(params['image_id']),
+      :thumb_url   => generate_thumb(user, mockups[0]['mockup_url']),
+      :mockup_url  => mockup_url,
+      #:printful_id => params['product_id'].to_i,
+      #:shopify_id  => 0
+    })
+
     #redirect_to mockups_path, notice: "Mockup was successfully created."
 
   end
diff --git a/app/helpers/template_helper.rb b/app/helpers/template_helper.rb
index ca6d1f0..b3d0e31 100644
--- a/app/helpers/template_helper.rb
+++ b/app/helpers/template_helper.rb
@@ -30,6 +30,22 @@ module TemplateHelper
         #type=CUT-SEW; model=All-Over Cut & Sew Women's Crew Neck
         #type=CUT-SEW; model=All-Over Cut & Sew Women's V-neck
         end
+      when "T-SHIRT"
+      if model.include? "T-Shirt"
+          product_title = "t-shirt"
+        end
+      when "SUBLIMATION"
+        if model.include? "PL301"
+          product_title = "aa_pl301"
+        elsif model.include? "PL308"
+          product_title = "aa_pl308"
+        elsif model.include? "PT332"
+          product_title = "la_pt332"
+        elsif model.include? "PT301"
+          product_title = "pt301"
+        elsif model.include? "PT356"
+          product_title = "la_pt356"
+        end
       when "FRAMED-POSTER"
         product_title = "8x10"
       when "MUG"
diff --git a/app/views/mockups/index.html.erb b/app/views/mockups/index.html.erb
index 785d8c9..3b628d4 100644
--- a/app/views/mockups/index.html.erb
+++ b/app/views/mockups/index.html.erb
@@ -21,15 +21,21 @@
         <td class=mockup><%= image_tag(mockup.product_url, alt: 'Product', width: '64') %></td>
         <td class=mockup> + </td>
         <td class=mockup><%= image_tag(mockup.image_url, alt: 'Image', width: '64') %></td>
-        <td class=mockup> = </td>
-        <td class=mockup><%= link_to(image_tag(mockup.thumb_url, alt: 'Mockup', width: '64'), mockup.mockup_url, target: '_blank') %></td>
-        <td class=mockup>
-          <% if mockup.shopify_id > 0 %>
-            <%= link_to 'Show', "https://la-camiseta-loca.myshopify.com/admin/products/" + mockup.shopify_id.to_s %>
-          <% else %>
-            <%= link_to "Create", {:controller => "mockups", :action => "new", :id => mockup.id.to_s} %>
-          <% end %>
-        </td>
+        <% if mockup.thumb_url %>
+          <td class=mockup> = </td>
+          <td class=mockup><%= link_to(image_tag(mockup.thumb_url, alt: 'Mockup', width: '64'), mockup.mockup_url, target: '_blank') %></td>
+          <td class=mockup>
+            <% if mockup.shopify_id > 0 %>
+              <%= link_to 'Show', "https://la-camiseta-loca.myshopify.com/admin/products/" + mockup.shopify_id.to_s %>
+            <% else %>
+              <%= link_to "Create", {:controller => "mockups", :action => "new", :id => mockup.id.to_s} %>
+            <% end %>
+          </td>
+        <% else %>
+          <td class=mockup></td>
+          <td class=mockup></td>
+          <td class=mockup></td>
+        <% end %> 
         <td class=mockup><%= link_to 'Destroy', mockup, method: :delete, data: { confirm: 'Are you sure?' } %></td>
       </tr>
     <% end %>

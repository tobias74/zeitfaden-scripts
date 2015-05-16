#!/usr/bin/env ruby

require 'csv'
require 'uri'
require 'net/http'
require 'rest_client'
require 'oauth2'
require 'json'
require 'time'
require 'exifr'
require 'digest/md5'
require 'fileutils'



puts 'Starting genral image upload for images potentially without location...'

authorization_code_value = ARGV.shift

client = OAuth2::Client.new('5556e6e3cd639701118','gWRioH9hU1q3ANgxiXDqnqhVEsernZ7DWYWlG6CA', :site => 'http://test.zeitfaden.com');
client.auth_code.authorize_url(:redirect_uri => 'http://myretrunlocalhost:8080/oauth2/callback')
token = client.auth_code.get_token(authorization_code_value, :redirect_uri => 'http://www.gaszmann.de/excel_oauth_app/', :headers => {'Authorization' => 'Basic some_password'})
puts token.to_hash
my_access_token = token.to_hash[:access_token]
puts my_access_token


 
myImages = Dir["*.jpg"] 

myImages.each { |image_file_name| 
  begin
    puts ''
    puts '------------------------'
    puts image_file_name 
    puts 'this is a ffile'
    
    exif_data = EXIFR::JPEG.new(image_file_name)
    
    if defined? exif_data.gps
      puts 'this has gps, please use android uploader'
    else
      puts 'this has no gps, ok.'
      item_id = Digest::MD5.hexdigest(exif_data.date_time.to_s + File.size(image_file_name).to_s)
      puts item_id
      puts "this is the date"
      puts exif_data.date_time.to_s
    
      application_data = {
        :height => exif_data.height,
        :width => exif_data.width,
        :item_id => item_id,
        :camera_model => exif_data.model,
        :exposure_time => exif_data.exposure_time.to_s,
        :iso_speed_ratings => exif_data.exif.iso_speed_ratings,
        :f_number => exif_data.f_number.to_f
      }
    
      post_data = {
        :uploadFile => File.new(image_file_name),
    
        :startTimestamp => exif_data.date_time.to_time.to_i,
        :endTimestamp => exif_data.date_time.to_time.to_i,
    
        :publishStatus => 'private',
        :appItemId => item_id,
        :appData => JSON.generate(application_data)
      }  
   

      puts "http://test.zeitfaden.com/station/getByAppItemId/appItemId/#{item_id}?access_token=#{my_access_token}"
      

      RestClient.get("http://test.zeitfaden.com/station/getByAppItemId/appItemId/#{item_id}?access_token=#{my_access_token}"){ |response, request, result, &block|
        puts "######################################################################################### this is the respinse code #{response.code}"
        case response.code
        when 200
          puts "do not do anything here"
          puts response
          puts result
        when 404
          puts "does not exist, we can insert."
          RestClient.post("http://test.zeitfaden.com/station/insertWithAppItemId/?access_token=#{my_access_token}", post_data ){ |response2, request2, result2, &block2|
            puts "######################################################################################### this is the respinse code #{response2.code}"
            case response2.code
            when 200
              p "It worked !"
              puts response2
              puts result2
              FileUtils.mv(image_file_name, 'done/' + image_file_name)
            when 423
              put "something 423?"
              exit
            else
              puts "SOMETHING WENT WRONG inside level 2, ABORTING."
              exit
            end
          }
          
        else
          puts "SOMETHING WENT WRONG, ABORTING."
          exit
        end
      }

   
    
      
    end
    
  

  end
  
  

  
}







      
exit











exit

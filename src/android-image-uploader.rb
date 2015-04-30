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



puts 'Starting...'

authorization_code_value = ARGV.shift

#client = OAuth2::Client.new('553cf9b43f5cb781589','SoPCz4GzYcUOUMfHpz1Bkw489uVdHDYA2OcBSSaR', :site => 'http://test.zeitfaden.com');
client = OAuth2::Client.new('554150b209dc9381571','Pi61iR9H7TkYjKC2CodP3RKGjwU7zrqoKxq2oAJw', :site => 'http://www.zeitfaden.com');

client.auth_code.authorize_url(:redirect_uri => 'http://myretrunlocalhost:8080/oauth2/callback')

token = client.auth_code.get_token(authorization_code_value, :redirect_uri => 'http://www.gaszmann.de/excel_oauth_app/', :headers => {'Authorization' => 'Basic some_password'})

puts token.to_hash
my_access_token = token.to_hash[:access_token]
puts my_access_token


 
myImages = Dir["*.jpg"] 

myImages.each { |image_file_name| 
  begin
    puts image_file_name 
    puts 'this is a ffile'
    
    exif_data = EXIFR::JPEG.new(image_file_name)
    
    
    #puts exif_data.gps.latitude.to_s
    #puts exif_data.gps.longitude.to_s
  
    item_id = Digest::MD5.hexdigest(exif_data.date_time.to_s + exif_data.gps.latitude.to_s + exif_data.gps.longitude.to_s + File.size(image_file_name).to_s)
    puts item_id
    #puts File.size(image_file_name).to_s
    #puts exif_data.date_time.to_s
    puts exif_data.model    
  
    application_data = {
      :item_id => item_id,
      :camera_model => exif_data.model,
      :exposure_time => exif_data.exposure_time.to_s,
      :f_number => exif_data.f_number.to_f
    }
  
    
  
#    RestClient.post("http://test.zeitfaden.com/station/upsertByAppItemId/?access_token=#{my_access_token}",
    RestClient.post("http://www.zeitfaden.com/station/upsertByAppItemId/?access_token=#{my_access_token}",
      :uploadFile => File.new(image_file_name),
      :startLatitude => exif_data.gps.latitude,
      :startLongitude => exif_data.gps.longitude,
      :endLatitude => exif_data.gps.latitude,
      :endLongitude => exif_data.gps.longitude,
  
      :startTimestamp => exif_data.date_time.to_time.to_i,
      :endTimestamp => exif_data.date_time.to_time.to_i,
  
      :publishStatus => 'private',
      :appItemId => item_id,
      :appData => JSON.generate(application_data)
      
    ){ |response, request, result, &block|
      puts "######################################################################################### this is the respinse code #{response.code}"
      case response.code
      when 200
        p "It worked !"
        puts response
        puts result
        FileUtils.mv(image_file_name, 'done/' + image_file_name)
        #File.rename(image_file_name, image_file_name + '.done');
      when 423
        put "something 423?"
        exit
      else
        puts "SOMETHING WENT WRONG, ABORTING."
        exit
       
      end
    }

  rescue NoMethodError
    puts "image did not have latitude longitude, not uploading"
    #File.delete(image_file_name)
  end
  
  

	
}







      
exit











exit

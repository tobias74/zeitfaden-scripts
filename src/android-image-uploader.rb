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


puts 'Starting...'

authorization_code_value = ARGV.shift

client = OAuth2::Client.new('image_uploader','123456', :site => 'http://test.zeitfaden.com');

client.auth_code.authorize_url(:redirect_uri => 'http://myretrunlocalhost:8080/oauth2/callback')


token = client.auth_code.get_token(authorization_code_value, :redirect_uri => 'http://asdlocalhost:8080/oauth2/callback', :headers => {'Authorization' => 'Basic some_password'})

puts token.to_hash
my_access_token = token.to_hash[:access_token]
puts my_access_token


 
myImages = Dir["*.jpg"] 

myImages.each { |image_file_name| 
	puts image_file_name 
	puts 'this is a ffile'
	
	a = EXIFR::JPEG.new(image_file_name)
	
    begin
	
		latitude = a.exif[0].gps_latitude[0].to_f + (a.exif[0].gps_latitude[1].to_f / 60) + (a.exif[0].gps_latitude[2].to_f / 3600)
		longitude = a.exif[0].gps_longitude[0].to_f + (a.exif[0].gps_longitude[1].to_f / 60) + (a.exif[0].gps_longitude[2].to_f / 3600)
		 
		longitude = longitude * -1 if a.exif[0].gps_longitude_ref == "W"   # (W is -, E is +)
		latitude = latitude * -1 if a.exif[0].gps_latitude_ref == "S"      # (N is +, S is -)

    rescue NoMethodError
		latitude = 0
		longitude = 0
	
	end
	
	
	puts latitude.to_s
	puts longitude.to_s

	myDate = EXIFR::JPEG.new(image_file_name).date_time

	item_id = Digest::MD5.hexdigest(image_file_name + myDate.to_s + latitude.to_s + longitude.to_s)
	puts item_id

    application_data = {
		:item_id => item_id,
    	:camera_model => EXIFR::JPEG.new(image_file_name).model,
		:exposure_time => EXIFR::JPEG.new(image_file_name).exposure_time.to_s,
		:f_number => EXIFR::JPEG.new(image_file_name).f_number.to_f
    }


	puts myDate.to_s
	

      RestClient.post("http://test.zeitfaden.com/station/upsert/?access_token=#{my_access_token}",
        :uploadFile => File.new(image_file_name),
        :startLatitude => latitude,
        :startLongitude => longitude,
        :endLatitude => latitude,
        :endLongitude => longitude,
		
        :startDate => myDate.to_s,
        :endDate => myDate.to_s,
		
        :publishStatus => 'public',
        :applicationItemId => item_id,
        :applicationData => JSON.generate(application_data)
        
      ){ |response, request, result, &block|
        puts "######################################################################################### this is the respinse code #{response.code}"
        case response.code
        when 200
          p "It worked !"
          #puts response
          #puts result
          #puts response.headers
          #response
        when 423
          put "something 423?"
          exit
          #raise SomeCustomExceptionIfYouWant
        else
          #puts response
          puts "SOMETHING WENT WRONG, ABORTING."
          exit
          
          #response.return!(request, result, &block)
        end
      }
      
      

	
}







      
exit











exit

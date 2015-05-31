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
require 'mini_exiftool'



puts 'Starting...'



 @to_decimal = lambda do |str|
   deg, dummy, min, sec = str.split(" ").map(&:to_f)
   if deg >= 0
     output = deg + (min / 60.0) + (sec / 3600.0)
   elsif deg <  #HARD EARNED KNOWLEDGE HERE
     output = deg - (min / 60.0) - (sec / 3600.0)
   end
   raise "something is wrong" if output.abs > 180
   output
 end



authorization_code_value = ARGV.shift

client = OAuth2::Client.new('554ca2986bd6d918568','3mnrEDNauxoy2S4omvlkegGBTjksAwmDSJ5xnSHS', :site => 'http://api.zeitfaden.com');

client.auth_code.authorize_url(:redirect_uri => 'http://myretrunlocalhost:8080/oauth2/callback')

token = client.auth_code.get_token(authorization_code_value, :redirect_uri => 'http://www.gaszmann.de/excel_oauth_app/', :headers => {'Authorization' => 'Basic some_password'})

puts token.to_hash
my_access_token = token.to_hash[:access_token]
puts my_access_token


 
myImages = Dir["*.mp4"] 

myImages.each { |image_file_name| 
  begin
    puts image_file_name 
    puts 'this is a ffile'
    

    exif = MiniExiftool.new(image_file_name)

    #puts File.mtime(image_file_name)
    #puts File.ctime(image_file_name)
    #puts File.birthtime(image_file_name)
    #exif.date_time_original = File.mtime(image_file_name)
    #puts exif.GPSLatitude
    #puts exif.GPSLongitude
    latitude = @to_decimal.call(exif.GPSLatitude).to_s
    longitude = @to_decimal.call(exif.GPSLongitude).to_s
    
    video_timestamp = exif.TrackCreateDate.to_time.to_i
    puts exif.TrackDuration


  
    item_id = Digest::MD5.hexdigest(video_timestamp.to_s + latitude.to_s + longitude.to_s + File.size(image_file_name).to_s)
    puts item_id
 #   puts exif.to_yaml
 #   puts "this is the date"
 #   puts exif_data.date_time.to_s
 #   puts exif_data.model    
  
    application_data = {
      :item_id => item_id,
      :avg_bitrate => exif.AvgBitrate,
      :duration => exif.TrackDuration
 #     :camera_model => exif_data.model,
 #     :exposure_time => exif_data.exposure_time.to_s,
 #     :f_number => exif_data.f_number.to_f
    }
  
    
  
    RestClient.post("http://api.zeitfaden.com/station/upsertByAppItemId/?access_token=#{my_access_token}",
      :uploadFile => File.new(image_file_name),
      :startLatitude => latitude,
      :startLongitude => longitude,
      :endLatitude => latitude,
      :endLongitude => longitude,
  
      :startTimezone => 'Europe/Berlin',
      :endTimezone => 'Europe/Berlin',
  
      :startTimestamp => video_timestamp,
      :endTimestamp => video_timestamp,
  
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
    puts "video did not have latitude longitude, not uploading"
    #File.delete(image_file_name)
  end
  
  

  
}







      
exit











exit

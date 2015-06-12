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



puts 'Starting genral video upload for videos potentially without location...'

authorization_code_value = ARGV.shift

client = OAuth2::Client.new('557b2a93567fc456683','1Hr0vTtAACj8Zm0ISWb8kZiJmo6Cek1f2sfxmJ7X', :site => 'http://api.zeitfaden.com');
client.auth_code.authorize_url(:redirect_uri => 'http://myretrunlocalhost:8080/oauth2/callback')
token = client.auth_code.get_token(authorization_code_value, :redirect_uri => 'http://www.gaszmann.de/excel_oauth_app/', :headers => {'Authorization' => 'Basic some_password'})
puts token.to_hash
my_access_token = token.to_hash[:access_token]
puts my_access_token


 
myImages = Dir["*.mov"] 

myImages.each { |image_file_name| 
  begin
    puts ''
    puts '------------------------'
    puts image_file_name 
    puts 'this is a ffile'
    
    exif = MiniExiftool.new(image_file_name)

    
    video_timestamp = exif.TrackCreateDate.to_time.to_i
    puts exif.TrackDuration
    puts Time.at(video_timestamp).to_s


  
    item_id = Digest::MD5.hexdigest(video_timestamp.to_s + File.size(image_file_name).to_s)
    puts item_id
  
    application_data = {
      :item_id => item_id,
      :avg_bitrate => exif.AvgBitrate,
      :duration => exif.TrackDuration
    }
  
  
    post_data = {
      :uploadFile => File.new(image_file_name),
  
      :startTimestamp => video_timestamp.to_i + 3600*2,
      :endTimestamp => video_timestamp.to_i + 3600*2,
  
      :publishStatus => 'private',
      :appItemId => item_id,
      :appData => JSON.generate(application_data)
    }  
  

    puts "http://api.zeitfaden.com/station/getByAppItemId/appItemId/#{item_id}?access_token=#{my_access_token}"
    

    RestClient.get("http://api.zeitfaden.com/station/getByAppItemId/appItemId/#{item_id}?access_token=#{my_access_token}"){ |response, request, result, &block|
      puts "######################################################################################### this is the respinse code #{response.code}"
      case response.code
      when 200
        puts "do not do anything here"
        puts response
        puts result
      when 404
        puts "does not exist, we can insert."
        RestClient.post("http://api.zeitfaden.com/station/insertWithAppItemId/?access_token=#{my_access_token}", post_data ){ |response2, request2, result2, &block2|
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

    
  
#    RestClient.post("http://api.zeitfaden.com/station/upsertByAppItemId/?access_token=#{my_access_token}",
#      :uploadFile => File.new(image_file_name),
#      :startLatitude => latitude,
#      :startLongitude => longitude,
#      :endLatitude => latitude,
#      :endLongitude => longitude,
#  
#      :startTimezone => 'Europe/Berlin',
#      :endTimezone => 'Europe/Berlin',
#  
#      :startTimestamp => video_timestamp,
#      :endTimestamp => video_timestamp,
  
#      :publishStatus => 'private',
#      :appItemId => item_id,
#      :appData => JSON.generate(application_data)
      
#    ){ |response, request, result, &block|
#      puts "######################################################################################### this is the respinse code #{response.code}"
#      case response.code
#      when 200
#        p "It worked !"
#        puts response
#        puts result
#        FileUtils.mv(image_file_name, 'done/' + image_file_name)
#      when 423
#        put "something 423?"
#        exit
#      else
#        puts "SOMETHING WENT WRONG, ABORTING."
#        exit
       
#      end
#    }


  end
  
  

  
}







      
exit











exit

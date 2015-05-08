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

myImages = Dir["*.jpg"] 

myImages.each { |image_file_name| 
  begin
    puts
    puts
    
    puts image_file_name 
    puts 'this is a ffile'


    exif = MiniExiftool.new(image_file_name)

    #puts File.mtime(image_file_name)
    #puts File.ctime(image_file_name)
    #puts File.birthtime(image_file_name)
    #exif.date_time_original = File.mtime(image_file_name)
    puts exif.date_time_original
    
    
    
    exif.date_time = exif.date_time_original
    exif.save
    
    
    
    #exif.save
    
  
  

#  rescue NoMethodError
#    puts "image did not have latitude longitude, not uploading"
    #File.delete(image_file_name)
  end
  
  

  
}







      
exit











exit

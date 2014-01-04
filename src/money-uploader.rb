#!/usr/bin/env ruby

require 'rubygems'
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

jsonFileName = ARGV.shift
authorization_code_value = ARGV.shift

client = OAuth2::Client.new('money_faden','123456', :site => 'http://test.zeitfaden.com');
client.auth_code.authorize_url(:redirect_uri => 'http://myretrunlocalhost:8080/oauth2/callback')
token = client.auth_code.get_token(authorization_code_value, :redirect_uri => 'http://asdlocalhost:8080/oauth2/callback', :headers => {'Authorization' => 'Basic some_password'})
puts token.to_hash
my_access_token = token.to_hash[:access_token]
puts my_access_token




json_data = JSON.parse( IO.read(jsonFileName) )


json_data.each {|values| 
	puts "-----------------------"
	puts values['applicationItemId']
	
	latitude = values['latitude']
	longitude = values['longitude']
	datetime = values['datetime']


	application_data = values['applicationData']
	
	puts application_data
	
	

      RestClient.post("http://test.zeitfaden.com/station/upsert/?access_token=#{my_access_token}",
        :uploadFile => File.new(values['imageFileName']),
        :startLatitude => latitude,
        :startLongitude => longitude,
        :endLatitude => latitude,
        :endLongitude => longitude,
		
        :startDate => datetime,
        :endDate => datetime,
		
        :publishStatus => 'public',
        :applicationItemId => values['applicationItemId'],
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

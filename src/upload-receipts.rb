#!/usr/bin/env ruby

require 'csv'
require 'uri'
require 'net/http'
require 'rest_client'
require 'oauth2'
require 'json'
require 'time'


puts 'Starting...'
 
csv_name = ARGV.shift
csv_name_out = ARGV.shift
authorization_code_value = ARGV.shift


client = OAuth2::Client.new('testclient','testpass', :site => 'http://test.zeitfaden.com');

client.auth_code.authorize_url(:redirect_uri => 'http://myretrunlocalhost:8080/oauth2/callback')
# => "https://example.org/oauth/authorization?response_type=code&client_id=client_id&redirect_uri=http://localhost:8080/oauth2/callback"


token = client.auth_code.get_token(authorization_code_value, :redirect_uri => 'http://asdlocalhost:8080/oauth2/callback', :headers => {'Authorization' => 'Basic some_password'})

puts token.to_hash
my_access_token = token.to_hash[:access_token]
puts my_access_token


#response = token.get('/oauth/resource/', :params => { 'query_foo' => 'bar' })
#puts response.parsed


#response.class.name
# => OAuth2::Response





CSV.open(csv_name, "r", {:headers => true, :col_sep => ";"}) do |csv|
  csv.find_all do |row|
    #puts row
    zettel_id = "#{row['prefix']}_#{row['ID']}"
    if row['ImageFilename'] && !row['ImageFilename'].empty? then
      image_file_name = "/home/tobias/work/zettel/all/#{row['ImageFilename']}"
      puts "Introducing Zettel with ID #{zettel_id}, trying to store filename: #{image_file_name}"
      puts "Using Access-Token: #{my_access_token}"

      application_data = {
        :merchant_name => row['Haendler'],
        :title => row['Titel'],
        :receipt_id => zettel_id,
        :tags => row['tags']
      }
      
      begin
        my_date = Time.parse(row['formatted_date'])
      rescue ArgumentError
        my_date = Time.at(0)
      end
      
      RestClient.post("http://test.zeitfaden.com/station/upsert/?access_token=#{my_access_token}",
        :uploadFile => File.new(image_file_name),
        :startLatitude => row['latitude'].to_f,
        :startLongitude => row['longitude'].to_f,
        :endLatitude => row['latitude'].to_f,
        :endLongitude => row['longitude'].to_f,
        :startDate => my_date.to_s,
        :endDate => my_date.to_s,
        :publishStatus => 'public',
        :applicationItemId => zettel_id,
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

      
    else
      #puts "nothgin"      
    end
    ##puts row['ID']
    #puts row.headers
    ##puts '#########################################end of row################################'
  end
end














exit


my_response = RestClient.post('http://test.zeitfaden.com/OAuth2/resource',
  :access_token => my_access_token
){ |response, request, result, &block|
  case response.code
  when 200
    p "It worked !"
    puts response
    puts result
    puts response.headers
    response
  when 423
    raise SomeCustomExceptionIfYouWant
  else
    response.return!(request, result, &block)
  end
}


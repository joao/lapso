require 'open-uri'
require 'json'

# Methods
# - search_endpoint
# - url_info
# - get_all_url_items
# - download_screenshot
# - process items


# Settings
URL = "publico.pt"
URL_FILE = "#{URL.gsub('.', '-')}_items.json"
MAX_ITEMS = 50
INITIAL_OFFSET = 0
URL_FILENAME = URL.gsub('.', '-')
DOWNLOAD_FOLDER = "img"
@total_items = 0
@oldest_item_date = 0
@newest_item_date = 0
response_items = []
SLEEP_DURATION = 2.5 # for screendshots


# Arquivo.pt search for URL
def search_endpoint(offset)
  return "http://arquivo.pt/textsearch?versionHistory=#{URL}&maxItems=#{MAX_ITEMS}&offset=#{offset}"
end


# Get URL info
def url_info
  info_json = open(search_endpoint(INITIAL_OFFSET))
  info = JSON.parse(info_json.read)
  total_items = info['total_items'].to_i
  @total_items = total_items

  # Newest date
  newest_timestamp = info['response_items'][0]['date'].to_i
  newest_date = Time.at(newest_timestamp).to_datetime
  @newest_item_date = newest_date

  # Oldest date
  info_json = open(search_endpoint(total_items - 1))
  info = JSON.parse(info_json.read)
  oldest_timestamp = info['response_items'][0]['date'].to_i
  oldest_date = Time.at(oldest_timestamp).to_datetime
  @oldest_item_date = oldest_date

end




# Get all the items of a URL
def get_all_url_items
  
  # Request information on the URL
  url_info

  puts
  puts "#{URL}"
  puts "Total items: #{@total_items}"
  puts "Newest item: #{@newest_item_date}"
  puts "Oldest item: #{@oldest_item_date}"
  puts

  puts "Retriving data:"
  begin

    number_of_requests = (@total_items / MAX_ITEMS).to_i + 1
    current_offset = 0

    # Make requests
    (0..number_of_requests).each_with_index do |request, index|

      puts "#{index+1}/#{number_of_requests}: #{current_offset}—#{(current_offset+MAX_ITEMS)} of #{@total_items}"
      info_json = open(search_endpoint(current_offset))
      info = JSON.parse(info_json.read)

      # join arrays
      response_items = response_items + info['response_items']

      # increment current_offset
      current_offset = current_offset + MAX_ITEMS
      puts

    end

    #puts response_items.to_json
    #puts response_items.size
    # Write JSON to file
    File.write("#{URL_FILE}", response_items.to_json)

  rescue
    puts "an error occurred retrieving items information"
  end

end



# Get screenshot
def download_screenshot(link_to_screenshot, timestamp)

    screenshot_filename = "#{URL_FILENAME}_#{timestamp}.png"
    screenshot_file = "#{DOWNLOAD_FOLDER}/#{screenshot_filename}"

    # Screenshot existance check
    unless File.file?(screenshot_file)
      puts "Downloading screenshot..."
      download = open(link_to_screenshot)
      IO.copy_stream(download, screenshot_file)
      puts
      sleep SLEEP_DURATION # to not overload the server with requests
    end

end


# Process items stored in JSON file
def process_items

  # Open file
  file = File.read("#{URL_FILE}")

  # File to hash
  data = JSON.parse(file)

  item_count = 0
  data.reverse.each do |item|

    # Get screenshot info
    link_to_screenshot = item['linkToScreenshot']
    timestamp = item['tstamp']
    
    puts "#{item_count+=1}: #{timestamp}"
    
    download_screenshot(link_to_screenshot, timestamp)

  end

end

process_items


exit






begin
  results_json = open(search_endpoint(INITIAL_OFFSET))
  results = JSON.parse(results_json.read)
  puts "Total items: #{results['total_items']}"

  items = results['response_items']
  puts "Items returned: #{items.size}"
  puts

  # Iterate over response
  items.each_with_index do |item, index|

    # Get item information
    screenshot_link = item['linkToScreenshot']
    timestamp = item['tstamp']
    screenshot_filename = "#{URL_FILENAME}_#{timestamp}.png"
    screenshot_file = "#{DOWNLOAD_FOLDER}/#{screenshot_filename}"
    puts "#{index+1}: #{URL} - #{timestamp}"

    # Screenshot existance check
    next if File.file?(screenshot_file)

    puts "Downloading screenshot..."
    download = open(screenshot_link)
    IO.copy_stream(download, screenshot_file)
    puts

  end


rescue

end
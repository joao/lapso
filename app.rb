require 'open-uri'
require 'json'

URL = "publico.pt"
MAX_ITEMS = 500
INITIAL_OFFSET = 5000
URL_FILENAME = URL.gsub('.', '-')
DOWNLOAD_FOLDER = "img"

# Arquivo.pt search for URL
def search(url, max_items, offset)
  return "http://arquivo.pt/textsearch?versionHistory=#{url}&maxItems=#{max_items}&offset=#{offset}"
end


begin
  results_json = open(search(URL, MAX_ITEMS, INITIAL_OFFSET))
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
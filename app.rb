require 'open-uri'
require 'json'
require 'mini_magick'
require 'date'

# Requires (besides the above Ruby gems):
# - imagemagick
# - ffmpeg
#
# Developed and test only on macOS,
# but should work on any *nix.

# Settings
# Methods
# - search_endpoint
# - url_info
# - get_all_url_items
# - download_screenshot
# - process items
# - write timestamp
# - create video


# Settings #####################################
URL = "publico.pt"
URL_FILE = "#{URL.gsub('.', '-')}_items.json"
MAX_ITEMS = 50
INITIAL_OFFSET = 0
URL_FILENAME = URL.gsub('.', '-')
JSON_DIR = "json"
URL.split('.').size == 2 ? IMG_DIR = "img/" + URL.split('.')[0] : IMG_DIR = "img/" + URL.split('.')[0] + URL.split('.')[1] # Images directory (screenshot and timestamped)
MOVS_DIR = "movs" # Movies export directory
SLEEP_DURATION = 6 # Interval to sleep between requesting screenshots
VIDEO_FPS = 10 # Experiment with this for a slower or faster video
DAYS_INTERVAL = 7 # Days interval, if there are lots of records in the same day


# Global variables
@total_items = 0
@oldest_item_date = 0
@newest_item_date = 0
@response_items = []


# Methods #####################################

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

    # Check if JSON dir exists
    Dir.mkdir(JSON_DIR) unless Dir.exist?(JSON_DIR)

    # Make requests
    (1..number_of_requests).each_with_index do |request, index|

      puts "#{index+1}/#{number_of_requests}: #{current_offset}—#{(current_offset+MAX_ITEMS)} of #{@total_items}"
      info_json = open(search_endpoint(current_offset))
      info = JSON.parse(info_json.read)

      # join arrays
      @response_items = @response_items + info['response_items']


      # increment current_offset
      current_offset = current_offset + MAX_ITEMS

    end

    # Write JSON to file
    File.write("#{JSON_DIR}/#{URL_FILE}", @response_items.to_json)

  rescue
    puts "an error occurred retrieving items information"
    exit
  end
  puts

end



# Get screenshot
def request_screenshot(link_to_screenshot, timestamp)

    # Check if IMG directory exists for this URL
    Dir.mkdir(IMG_DIR) unless Dir.exist?(IMG_DIR)

    screenshot_filename = "#{URL_FILENAME}_#{timestamp}.png"
    screenshot_file = "#{IMG_DIR}/#{screenshot_filename}"

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
def download_screenshots

  puts "Downloading screenshots..."

  # Open file
  file = File.read("#{JSON_DIR}/#{URL_FILE}")

  # File to hash
  data = JSON.parse(file)
  data_size = data.size

  item_count = 0
  previous_day = Date.parse(data.reverse[0]['tstamp'])
  data.reverse.each_with_index do |item, index|

    # Get screenshot info
    link_to_screenshot = item['linkToScreenshot']
    timestamp = item['tstamp']

    puts "#{item_count+=1}/#{data_size}: #{timestamp}"

    #current_date = item['tstamp'][0..8].to_i
    current_day = Date.parse(timestamp)
    if (current_day == previous_day && index != 0) || (current_day < previous_day)
      #previous_day = current_day
      puts "Same day or not in #{DAYS_INTERVAL} days interval, skipping..."
      next
    end
    previous_day = current_day + DAYS_INTERVAL

    request_screenshot(link_to_screenshot, timestamp)

  end

end


# Write timestamp in images
def write_timestamp

  puts "Writing timestamps..."

  # Write timestamp output dir
  timestamp_dir = "#{IMG_DIR}/timestamp"
  Dir.mkdir(timestamp_dir) unless Dir.exist?(timestamp_dir)

  # Get all the screenshots of the URL
  screenshots = Dir.glob("#{IMG_DIR}/*.png").sort
  screenshots_total = screenshots.size

  # Iterate over the screenshots
  screenshots.each_with_index do |screenshot, index|
    # Extract date from filename
    date = screenshot.split('_')[1].split('.')[0]
    year = date[0..3]
    month = date[4..5]
    day = date[6..7]
    hour = date[8..9]
    minutes = date[10..11]
    seconds = date[12..13]
    puts "#{index+1}/#{screenshots_total}: #{day}/#{month}/#{year} - #{hour}:#{minutes}"

    timestamp = "\'#{day}/#{month}/#{year}\'"
    timestamp_with_hour = "\'#{day}/#{month}/#{year} - #{hour}:#{minutes}\'"

    # Write timestamp and crop image for 720p video
    img = MiniMagick::Image.open(screenshot)
    img.resize "1280x"
    img.crop "0x720+0+0"
    img.combine_options do |i|
      i.fill "black"
      i.stroke "black"
      i.strokewidth 1
      # top corner, top  top, top-left !?! still have no clue...
      i.draw "rectangle 1016,632 1232,688"
      i.gravity "Northeast"
      i.fill "white"
      i.undercolor "black"
      i.stroke "white"
      i.strokewidth 1
      i.font "Courier"
      i.weight "bold"
      i.pointsize 32
      i.strokewidth 2
      i.draw "text 60,650 #{timestamp}"
    end

    img.write(timestamp_dir + "/" + screenshot.split('/')[-1].split('.')[0] + ".png")

  end

end


# Create Video from timestamped screenshots
def create_video
  puts "Creating video..."

  # Check if video folder exists
  Dir.mkdir(MOVS_DIR) unless Dir.exist?(MOVS_DIR)

  # FFMPEG conversion of image sequence into video
  ffmpeg_command = "ffmpeg -r #{VIDEO_FPS} -pattern_type glob -i \'#{IMG_DIR}/timestamp/*.png\' -s hd720 -vcodec libx264 -crf 18 -preset slow -pix_fmt yuv420p #{MOVS_DIR}/#{URL_FILENAME}.mp4"
  system(ffmpeg_command)

  puts "Video created! :)"
end

# Cleanup
def cleanup
  # TODO: delete files after use
end



# Run app #####################################
def run
  get_all_url_items
  download_screenshots
  write_timestamp
  create_video
end

run

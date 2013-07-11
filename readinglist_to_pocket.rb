#!/usr/bin/env USER_FOLDER/.rvm/bin/rvm 1.9.2@pocket do ruby
require 'bundler/setup'

require 'net/https'
require 'uri'
require 'terminal-notifier-guard'
require 'nokogiri-plist'
require 'date'
#TerminalNotifier::Guard.notify "Running!"
# MY POCKET ACCESS KEY
# See readme for how to obtain this
my_pocket_access_key = 'aaaaaaaa-bbbb-cccc-dddd-eeeeee'
my_pocket_tags = 'safari' # comma separated tags to mark Reading List posts by - no spaces!

# Our last run
# Setting this to epoch time in case this is our first time
# or we don't have a last run file
lastrun = Time.at(0).to_s

# Our last run file
# Store it on dropbox if you want to have it sync across computers
lastrun_file = "/tmp/readinglist_pocket_run"

# If our timestamp file exists, read it in
if (File.exists? File.expand_path(lastrun_file))
  lastrun = File.open(File.expand_path(lastrun_file), 'rb').read
end

# The real last run, which will either be epoch time
# or the content of the last run file
lastrun_dt = DateTime.parse(lastrun)

# Standard Pocket credentials
pocket = 'getpocket.com'
pocket_consumer_key = '16305-b183e9e83655d260cddc5abc'
pocket_app_name = 'Reading List to Pocket'

# My Array of Links to send to Instapaper
links = Array.new

# Open the binary Bookmarks plist and convert to xml, read it in
input = %x[/usr/bin/plutil -convert xml1 -o - ~/Library/Safari/Bookmarks.plist]
# Let's parse the plist and find the elements we care about
# There's probably a better way to do this, but I'm stupid at Ruby
# This also seems ripe for refactoring, but I'm lazy
plist = Nokogiri::PList(input)
if plist.include? 'Children'
  plist['Children'].each do |child|
    child.keys.each do |ck|
      if child[ck].is_a? Array
        child[ck].each do |list|
          if list.include? 'ReadingList'
            datefetched = list['ReadingList']['DateAdded']
            # Text not included right now, but available for when it is needed
            text = URI::escape(list['ReadingList']['PreviewText'] || "")
            title = URI::escape(list['URIDictionary']['title'] || "")
            uri = URI::escape(list['URLString'])
            if (!datefetched.nil? && (datefetched > lastrun_dt))
              links << {:uri => uri, :title => title, :text => text}
            end
          end
        end
      end
    end
  end
end

# Apparently we can't use SSL to post stuff, it seems to cause a 400
# When we can, uncomment this stuff below.
# The ca-bundle.crt file is needed thanks to http://stackoverflow.com/questions/11703679/opensslsslsslerror-on-heroku/16983443
#http = Net::HTTP.new(pocket, 443)
#http.use_ssl = true
#http.verify_mode = OpenSSL::SSL::VERIFY_PEER
#http.ca_file = File.join(File.expand_path(File.dirname(__FILE__)),'ca-bundle.crt').to_s

http = Net::HTTP.new(pocket, 80)
http.use_ssl = false

# Let's loop through our links and add them to pocket
links.each do |link|
  query_string = "/v3/add?url=#{link[:uri]}&title=#{link[:title]}&tags=#{my_pocket_tags}&consumer_key=#{pocket_consumer_key}&access_token=#{my_pocket_access_key}"
  request = Net::HTTP::Get.new(query_string)
  response = http.request(request)

  # Throw up a system notify message - 10.8 and later only
  # TODO: Find a way to make the app name less ugly
  if ( response.code == '200' || response.code == '201' )
    TerminalNotifier::Guard.success "Successfully added #{link[:uri]}",
                                     :app_name => pocket_app_name,
                                     :title => "Successfully added item to Pocket",
                                     :group => Process.pid
  else
    TerminalNotifier::Guard.failed "Could not add #{link[:uri]}",
                                     :app_name => pocket_app_name,
                                     :title => "Error adding item to Pocket [#{response.code}]",
                                     :group => Process.pid
  end
end

# Let's write our successful run out
# Only write out when we have links, so that we don't save a file every
# time a bookmark changes
if ( links.length > 0 )
  File.open(File.expand_path(lastrun_file), 'w') {|f| f.write(DateTime.now.to_s) }
end


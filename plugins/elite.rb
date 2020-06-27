require 'net/http'
require 'erb'

# the API this was going to use has closed their doors and I cba to go through the verification process
# so instead this is here more as an artifact/reference I can pull from later for future projects.

class ED
  include ERB::Util

  def initialize
    @ed_api_key = ENV['ed_api_key']
    @cmdr       = ENV['ed_commander_name']
  end

  def call(args)
    if args.empty?
      return {
        text: 'Please enter a location!',
        type: 'text'
      }
    else
      commander = args[0]
      uri = URI("https://inara.cz/inapi/v1/")

      request_params = {
        header: {
          commanderName: @cmdr,
          appName:       "discord_bot_plugin",
          appVersion:    "1.00",
          isDeveloped:   true,
          APIkey:        @ed_api_key,
        },
        events: [
          "eventName": "getCommanderProfile",
          "eventData": {
            "searchName": commander
          }
        ]
      }

      # set up the HTTP request
      request_header   = {'Content-Type': 'application/json'}
      http             = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl     = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      
      request      = Net::HTTP::Post.new(uri.path, request_header)
      request.body = request_params.to_json
      
      response = http.request(request)
      @profile = JSON.parse(response.body)
    end
  end
end

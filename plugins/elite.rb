require 'net/http'
require 'erb'

class ED
  include ERB::Util

  def call(args)
    if args.nil?
      return {
        data: help(),
        type: 'text'
      }
    else
      uri = URI("https://eddb.io/archive/v6/stations.json")
      mode = args[0]
      @search_query = args[1..-1].join(' ')

      # parse the message for appropriate info
      #   in both cases every arg past the first should be combined as the value

      #case mode
      #when "station"

      #when "item"

      #else
      #  return help()
      #end

      # set up the HTTP request
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      response = http.get(uri.request_uri)
      @eddb_info = JSON.parse(response.body)

      return {
        data: build_embed(mode),
        type: 'embed'
      }
    end
  end

  def build_embed(mode)
    fields = []

    case mode
    when "item"
      fields << {"Stations": ["station A", "station B", "station C"].join("\n")}
    when "station"
      fields << {"System": "Waffle BQ-79 I3"}
      fields << {"Commodoties": ["waffles", "pancakes", "biscuits"].join("\n")}
    end

    forecast = {
      header: "Results for #{@search_query}",
      fields: fields
    }
  end


  # help text for the plugin
  def help()
    possible_commands = {
      forecast: [
        "**Command:** `edsearch`",
        "**Description:** looks up item or station info from the EDDB API",
        "**Usage:**",
        "\t`!lilybot edsearch station Sun Takush`",
        "\t`!lilybot edsearch item Thrusters A1`",
      ]
    }
    msg = ''
    possible_commands.keys().each do |command|
      msg += possible_commands[command].join("\n")
      msg += "\n"
    end
    msg
  end
end

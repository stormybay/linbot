require 'net/http'
require 'tempfile'
require 'chromedriver-helper'
require 'selenium-webdriver'
require 'erb'

class Forecast
  include ERB::Util

  def initialize
    @weather_api_key = ENV['weather_api_key']
    @location = ''
    @forecast = {}
    @units = {
      'f': '&units=imperial',
      'c': '&units=metric'
    }
  end

  def call(args)
    if args.nil?
      return {
        text: help(),
        type: 'text'
      }
    else
      chosen_units = args[0].downcase

      if chosen_units == 'c' || chosen_units == 'f'
        units = @units[chosen_units.to_sym]
        @unit_abbreviation = chosen_units.upcase
        @location = args[1..-1].join(' ')
      else
        units = '&units=imperial'
        @unit_abbreviation = 'F'
        @location = args[0..-1].join(' ')
      end

      uri = URI.parse("https://api.openweathermap.org/data/2.5/weather?q=#{@location}&appid=#{@weather_api_key}#{units}")

      # set up the HTTP request
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      response = http.get(uri.request_uri)
      @forecast = JSON.parse(response.body)

      return {
        data: build_embed(),
        type: 'embed'
      }
    end
  end

  def build_embed
    forecast = {
      "header":       @location.split(' ').map{|w| w.capitalize}.join(' '),
      "footer":       "https://linbot-server.herokuapp.com/images/#{@forecast["weather"][0]["main"]}.jpg",
      "Forecast":     @forecast["weather"][0]["description"],
      "Current temp": "#{@forecast["main"]["temp"]} #{@unit_abbreviation}",
      "Feels like":   "#{@forecast["main"]["feels_like"]} #{@unit_abbreviation}",
      "High":         "#{@forecast["main"]["temp_max"]} #{@unit_abbreviation}",
      "Low":          "#{@forecast["main"]["temp_min"]} #{@unit_abbreviation}",
      "Wind":         "#{@forecast["wind"]["speed"]} #{@unit_abbreviation == "F" ? "mph" : "km/h"}",
      "Humidity":     "#{@forecast["main"]["humidity"]}%"  
    }
  end

  # help text for the plugin
  def help()
    possible_commands = {
      forecast: [
        "**Command:** `forecast`",
        "**Description:** Retrieves the current forecast for a location",
        "**Usage:**",
        "\t`!linbot forecast Chicago`",
        "\t`!linbot forecast -c Chicago`",
        "\t`!linbot forecast Chicago, Illinois`",
        "**Notes:**",
        "\t`-c` will display the forecast in metric, omit for imperial"
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

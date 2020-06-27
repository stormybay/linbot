require 'net/http'
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
    if args.empty?
      return {
        text: 'Please enter a location!',
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

      server_url = build_server_query()
      
      return {
        text: get_image(server_url),
        type: 'image'
      }
    end
  end

  def get_image(url)
    # initialize Selenium
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless')
    driver = Selenium::WebDriver.for(:chrome, options: options)

    # navigate Selenium to the image server
    driver.navigate.to(url)

    # resize window and take a screenshot
    file_name = "./plugins/tmp/screenshot-#{rand(1..50)}.png"
    driver.manage.window.resize_to(300, 172)
    driver.save_screenshot(file_name)

    # stop the selenium driver
    driver.quit

    #return the filename of the screenshot that was saved
    return file_name
  end

  def build_server_query
    image_server = "http://localhost:8003/forecast"

    query_data = {
      location:        @location,
      weather_main:    @forecast["weather"][0]["main"],
      weather_descrip: @forecast["weather"][0]["description"],
      actual_temp:     @forecast["main"]["temp"],
      feels_temp:      @forecast["main"]["feels_like"],
      high_temp:       @forecast["main"]["temp_max"],
      low_temp:        @forecast["main"]["temp_min"],
      wind:            @forecast["wind"]["speed"]
    }
  
    query = "?units=#{@unit_abbreviation}"

    query_string = query_data.keys.each do |metric|
      sanitized_metric = url_encode(query_data[metric])
      query += "&#{metric.to_s}=#{sanitized_metric}"
    end

    "#{image_server}#{query}"
  end

  # help text for the plugin
  def help(command=nil)
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

    if !command.nil? && possible_commands.key?(command)
      return possible_commands[command].join("\n")
    else
      return 'That command is not part of this plugin!'
    end
  end
end

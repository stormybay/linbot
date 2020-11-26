require 'net/http'
require 'chromedriver-helper'
require 'selenium-webdriver'
require 'erb'

class ServerStatus
  include ERB::Util

  def initialize
    @possible_games = {
      'starbound': 21025
    }
  end

  def call(args)
    if args.nil?
      return {
        text: help(),
        type: 'text'
      }
    else
      return {
        text: get_status(args[0]),
        type: 'text'
      }
    end
  end

  def get_status(game)
    game = game.to_sym
    if !@possible_games.keys().include?(game)
      return "I don't know about that game!"
    end

    is_running = `netstat -an | grep LIST | grep #{@possible_games[game]}`
    return is_running.empty? ? "🔴 #{game} is down! Please notify Lily" : "🟢 #{game} is running!"
  end

  # help text for the plugin
  def help()
    possible_commands = {
      server: [
        "**Command:** `server`",
        "**Description:** retrieves the status of a game server",
        "**Usage:**",
        "\t`!lilybot server starbound`",
        "**Possible games:**",
        "#{@possible_games.keys().map{|game| "- #{game}"}.join("\n")}"
      ],
    }
    msg = ''
    possible_commands.keys().each do |command|
      msg += possible_commands[command].join("\n")
      msg += "\n"
    end
    msg
  end
end

require 'discordrb'
require_relative './plugins/forecast.rb'
require_relative './plugins/server_status.rb'

bot_token         = ENV['linbot_token']
bot               = Discordrb::Bot.new(token: bot_token, ignore_bots: true)
prefix            = '!linbot'
possible_commands = {
  forecast: {
    instance:    Forecast.new,
    description: 'Retrieves the current forecast for a location.'
  },
  server: {
    instance:    ServerStatus.new,
    description: 'Retrieves the status of a game server.'
  }
}

bot.ready do |e|
  puts "#{bot.profile.username} is firing on all cylinders!"
end

bot.message do |e|
  msg = e.message.content

  # check for commands
  if msg.start_with?(prefix)
    msg_split = msg.split(' ')

    # if there is no command given
    if msg_split.length < 2
      e.respond('uwot m8? Try again, this time with an actual command.')
    else
      cmd  = msg_split[1].to_sym
      args = msg_split.length >= 3 ? msg_split[2..-1] : nil

      # if the command is valid, parse its args and instantiate the plugin with them
      if possible_commands.keys.include?(cmd)
        plugin = possible_commands[cmd][:instance]
        res    = plugin.call(args)

        case res[:type]
        when 'text'
          e.respond(res[:text])
        when 'image'
          #stream = "data:image/png;base64,#{res[:text]}"
          stream = res[:text]
          e.send_file(File.open(res[:text], 'r'))
          File.delete(res[:text])

          #e.channel.send_embed("waffles") do |embed|
          #  embed.title = "title ~~(did you know you can have markdown here too?)~~"
          #  embed.colour = 0x3c34f9
          #  embed.url = "https://discordapp.com"
          #  embed.description = "this supports [named links](https://discordapp.com) on top of the previously shown subset of markdown. ```\nyes, even code blocks```"
          #  embed.timestamp = Time.at(1593807519)
          #end

          #File.delete(res[:text])
        end
      elsif cmd == :help
        commands = possible_commands.keys()
        help_msg = "**Possible Commands**\n"

        commands.each do |c|
          help_msg += "> `#{c}`: #{possible_commands[c][:description]}\n"
        end

        e.respond(help_msg)
      else
        e.respond('No idea what that command is, try again.')
      end
    end
  end
end

# start the bot
bot.run()

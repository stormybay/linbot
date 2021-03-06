require 'discordrb'
require 'discordrb/webhooks'
Dir["./plugins/*.rb"].each {|f| require f}

bot_token         = ENV['lilybot_token']
bot               = Discordrb::Bot.new(token: bot_token, ignore_bots: true)
prefix            = '!lilybot'
possible_commands = {
  forecast: {
    instance:    Forecast.new,
    description: 'Retrieves the current forecast for a location.',
    active:      true
  },
  convert: {
    instance:    Converter.new,
    description: 'Converts the given temperature into other units',
    active:      true
  },
  time: {
    instance:    TimePlugin.new,
    description: 'Returns time in the different timezones',
    active:      true
  },
  roll: {
    instance:    Roll.new,
    description: 'Rolls a dice of the amount and sides specified.',
    active:      true
  },
  edsearch: {
    instance:    ED.new,
    description: 'Queries EDDB json API to allow for quick searching of items',
    active:      true
  }
 # not used currently but keeping incase I re-activate the servers.
 # server: {
 #   instance:    ServerStatus.new,
 #   description: 'Retrieves the status of a game server.',
 #   active:      false
 # }
}

bot.ready do |e|
  puts "Lilybot is firing on all cylinders!"
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
      if possible_commands.keys.include?(cmd) && possible_commands[cmd][:active]
        plugin = possible_commands[cmd][:instance]
        res    = plugin.call(args)

        case res[:type]
        when 'text'
          e.respond(res[:data])
        when 'embed'
          d = res[:data]
          e.channel.send_embed() do |embed|
            embed.title  = d[:header]
            embed.colour = 0xffd1dc

            if d[:image] 
              embed.image = Discordrb::Webhooks::EmbedImage.new(url: d[:image])
            end

            d[:fields].each do |f|
              name = f.keys[0]
              embed.add_field(name: name, value: f[name])
            end
          end
        end
      elsif cmd == :help
        commands = possible_commands.keys()
        help_msg = "**Possible Commands**\n"

        commands.each do |c|
          if possible_commands[c][:active]
            help_msg += "> `#{c}`: #{possible_commands[c][:description]}\n"
          end
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

require 'discordrb'
require_relative './plugins/forecast.rb'
require 'pry'

bot_token         = ENV['linbot_token']
bot               = Discordrb::Bot.new(token: bot_token, ignore_bots: true)
sessions          = {}
disclaimer        = ''
prefix            = '!linbot'
possible_commands = {
  forecast: {
    instance:    Forecast.new,
    description: 'Retrieves the current forecast for a location'
  }
}
possible_angry_emotes = [
  "<:aight:708721212767076473>",
  "<:aight:716379289548750918>",
  "<:farfaA:667005188187488267>",
  "😠",
  ">:("
]

# load in the disclaimer
data = File.foreach('disclaimer.txt') do |line|
  disclaimer += line
end

bot.ready do |e|
  puts "#{bot.profile.username} is firing on all cylinders!"
end

bot.message do |e|
  msg = e.message.content

  # check for angry emotes!
  if possible_angry_emotes.include?(msg)
    e.respond(disclaimer)
  end

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
        res = plugin.call(args)

        case res[:type]
        when 'text'
          e.respond(res[:text])
        when 'image'
          e.send_file(File.open(res[:text], 'r'))
          File.delete(res[:text])
        end
      elsif cmd == :help
        commands = possible_commands.keys

        if args.nil?
          help_msg = "**Possible Commands**\n"

          commands.each do |c|
            help_msg += "> `#{c}`: #{possible_commands[c][:description]}\n"
          end
        else
          cmd = args[0].to_sym

          if possible_commands.keys.include?(cmd)
            help_msg = possible_commands[cmd][:instance].help(cmd)
          else
            help_msg = 'No idea what that command is, try again.'
          end
        end

        e.respond(help_msg)
      else
        e.respond('No idea what that command is, try again.')
      end
    end
  end
end

bot.run()

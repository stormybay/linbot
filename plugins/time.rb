require 'time'

class TimePlugin

  def call(args)
    return get_time(args)
  end

  def get_time(args=nil)
    # https://www.epochconverter.com/timezones

    # may want to add flags later, so keeping it as a hash for now.
    time_zones = {
      "HST":     {"offset": -36000},
      "AKDT":    {"offset": -28800},
      "PDT/MST": {"offset": -25200},
      "MDT":     {"offset": -21600},
      "CDT":     {"offset": -18000},
      "EDT":     {"offset": -14400},
      "BST":     {"offset": 3600},
      "CEST":    {"offset": 7200},
      "JST":     {"offset": 32400},
      "AEST":    {"offset": 36000},
      "ACST":    {"offset": 34200},
      "AWST":    {"offset": 28800},
    }

    # DateTime.parse('Sat, 3 Feb 2001 04:05:06 +0700')
    if !args.nil?
      if args[0] == "now" || args[0] == "current"
        # this will use the timezone of the machine hosting the bot.
        t = Time.now
        header = "Current Time"
      else
        begin
          t = Time.rfc2822(args.join(' '))
          header = "Time for #{t}"
        rescue ArgumentError => e
          return {
            data: "`Invalid time passed, please see below for help on the expected format.`\n\n#{help()}",
            type: 'text'
          }
        end
      end
    else
      return {
        data: help(),
        type: 'text'
      }
    end

    # take the timezone of the given time object and convert to UTC
    utc = Time.parse(t.to_s).utc
    embed_str = ""
    time_zones.keys.each do |z|
      embed_str += "**#{z}** - #{(utc + time_zones[z][:offset]).strftime("%A, %m/%d/%Y, %T")}\n"
    end

    data = {
      header: header,
      fields: [
        {"Times": embed_str}
      ]
    }

    return {
      data: data,
      type: "embed"
    }
  end

  # help text for the plugin
  def help()
    possible_commands = {
      time: [
        "**Command:** `time`",
        "**Description:** Tells the time in various timezones",
        "**Usage:**",
        "\t`!lilybot time now`",
        "\t`!lilybot time current`",
        "\t`!lilybot time Sat, 25 Jul 2020 16:30:00 +0600`",
        "**Notes:**",
        "\t- You can use either 'now' or 'current' to get the current time",
        "\t- Due to how frustrating parsing dates typically is, the bot will expect it to be in the above format if you wish to give it a specific time.",
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

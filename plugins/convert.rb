class Converter

  def call(args)
    if args.nil?
      return {
        data: help(),
        type: 'text'
      }
    else
      return {
        data: convert(args),
        type: 'text'
      }
    end
  end

  # convert the passed temp
  def convert(args)
    temp_args = args.length > 1 ? args[0..2].join('') : args[0]
    temp  = temp_args.match(/(\-?\d+)/).nil? ? nil : temp_args.match(/(\-?\d+)/)[1].to_i
    units = temp_args.match(/\-?\d+([ckfCKF])/).nil? ? nil : temp_args.match(/\-?\d+([ckfCKF])/)[1].downcase

    if temp.nil?
      return help()
    else
      units = "f" unless !units.nil?
      new_temps = ""

      # use current units to determine which other units to add in the message
      case units
      when "f"
        new_temps += "#{((temp - 32) * (5/9r)).to_f.round(2)}C\n"             # C
        new_temps += "#{(((temp - 32) * (5/9r)).to_f + 273.15).round(2)}K\n"    # K
      when "c"
        new_temps += "#{((temp * (9/5r)) + 32).to_f.round(2)}F\n"             # F
        new_temps += "#{(temp + 273.15).round(2)}K\n"                         # K
      when "k"
        new_temps += "#{(temp - 273.15).round(2)}C\n"                           # C
        new_temps += "#{(((temp - 273.15) * (9/5r)).to_f + 32).round(2)}F\n"    # F
      else
        return "Invalid units specified, please use either K, F, or C. If none are passed it will default to F."
      end

      return "```\n#{new_temps}\n```"
    end
  end

  # help text for the plugin
  def help()
    possible_commands = {
      convert: [
        "**Command:** `convert`",
        "**Description:** Converts the given temperature into other units",
        "**Usage:**",
        "\t`!linbot convert 32F`",
        "\t`!linbot convert 0C`",
        "\t`!linbot convert 0 C`",
        "**Notes:**",
        "\t- Units are not case sensitive",
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

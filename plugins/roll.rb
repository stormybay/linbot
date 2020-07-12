class Roll

  def call(args)
    if args.nil?
      return {
        data: help(),
        type: 'text'
      }
    else
      return {
        data: generate_roll(args[0]),
        type: 'text'
      }
    end
  end

  # simulate the specified dice rolls
  def generate_roll(dice)
    rolls        = []
    roll_counter = dice.match(/(\d+)d/).nil? ? nil : dice.match(/(\d+)d/)[1].to_i
    sides        = dice.match(/d(\d+)/).nil? ? nil : dice.match(/d(\d+)/)[1].to_i

    # the modifier will only not be nil if they have add a valid number after the operator, so it checks both.
    modifier     = dice.match(/d\d+([+-])/).nil? ? nil : dice.match(/d\d+([+-])(\d+)/)

    if sides.nil? || sides < 1
      return help()
    else
      if !roll_counter.nil?
        roll_counter.times do
          rolls << rand(0..sides)
        end
      else
        rolls << rand(0..sides)
      end
    end

    build_response(rolls, modifier)
  end

  # build the discord message to send back with the rolls
  def build_response(rolls, modifier)
    sum = 0
    msg = "```\n"
    rolls.each_with_index do |roll, index|
      msg += "Roll ##{index+1}: #{roll}\n"
      sum += roll
    end
    msg += "-----\nTotal: #{sum}"

    if !modifier.nil?
      amt = modifier[2].to_i
      case modifier[1]
      when "+"
        sum += amt
        msg += " + #{amt} = #{sum}"
      when "-"
        sum -= amt
        msg += " - #{amt} = #{sum}"
      end
    end
    msg += "\n```"
    msg
  end

  # help text for the plugin
  def help()
    possible_commands = {
      forecast: [
        "**Command:** `roll`",
        "**Description:** Rolls a dice of the amount and sides specified",
        "**Usage:**",
        "\t`!linbot roll 1d20-3`",
        "\t`!linbot roll 2d20+1`",
        "\t`!linbot roll 1d20`",
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

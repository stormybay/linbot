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

    # check sides
    if sides.nil? || sides <= 1 || sides > 100
      return "Please specify a dice with a proper number of sides (at least 2, no more than 100)"
    end

    if !roll_counter.nil?
      # check roll counter
      if roll_counter == 0 || roll_counter > 16
        return "The minimum number of rolls is one, and the max is 16. You may do `!linbot roll d20` however instead of `!linbot roll 1d20`"
      end

      roll_counter.times do
        rolls << rand(1..sides)
      end
    else
      rolls << rand(1..sides)
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
        "\t`!linbot roll d20`",
        "**Notes:**",
        "\t- You may have from 2-16 rolls in a single command, i.e `2d20` to `16d20`",
        "\t- Dice can range from 2 to 100 sides, i.e `d2` to `d100`",
        "\t- There is currently no cap to the modifier, i.e `2d20+1000000` is valid.",
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

# Linbot

A simple discord bot written in ruby

## Technical Info
- Language: Ruby 2.7.1
- Bundler Version: 2.1.4
- Libs: [discordrb](https://github.com/discordrb/discordrb)

## Prerequisites
Make sure you have the following environment variables in your `~/.bashrc` or `~/.bash_profile`:
- `linbot_token` from [Discord's dev services](https://discord.com/developers)
- `weather_api_key` from [OpenWeatherMap API](https://openweathermap.org/)

You can do this via for example:
- `export weather_api_key=1234546abcdef-12345`

## App Setup
- clone the repo and cd into it
- make sure you have Ruby `2.7.1` installed with bundler `2.1.4`
- `export RACK_ENV=development`
- `bundle install --path vendor/bundle`
- `bundle exec ruby bot.rb`

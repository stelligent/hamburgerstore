#!/usr/bin/env ruby

require 'hamburgerstore'
require 'aws-sdk'
require 'trollop'

SUB_COMMANDS = %w(store retrieve)
global_opts = Trollop.options do
  opt :region, 'The region to look for the dynamodb in', default: 'us-east-1'
  banner 'utility for storing and retrieving encrypted values
  available commands:

    store -- store a value in hamerburger store
    retrieve -- retrieve a value from hambuger store

  use --help with either command for more information.
  '
  stop_on SUB_COMMANDS
end

cmd = ARGV.shift
cmd_opts =
  case cmd
  when 'store'
    Trollop.options do
      opt :identifier, 'the name of the key associated with the value', required: true, type: String
      opt :keyname, 'the name of the key associated with the value', required: true, type: String
      opt :value, 'the value to be inserted into the keystore (required for store)', required: true, type: String
      opt :kmsid, 'the kms key id to use to encrypt the data (required for store)', required: true, type: String
      opt :table, 'the name of the table to perform the lookup on', required: true, type: String
    end
  when 'retrieve'
    Trollop.options do
      opt :identifier, 'the name of the key associated with the value', required: true, type: String
      opt :keyname, 'the name of the key associated with the value', required: true, type: String
      opt :table, 'the name of the table to perform the lookup on', required: true, type: String
    end
  else
    Trollop.die 'usage: hamburgerstore.rb [store|retrieve] [parameters]'
  end

hamburger = HamburgerStore.new(table_name: cmd_opts[:table], key_id: cmd_opts[:kmsid], region: global_opts[:region])

case cmd
when 'store'
  begin
    hamburger.store(cmd_opts[:identifier], cmd_opts[:keyname], cmd_opts[:value])
  rescue StandardError => e
    puts "#{e.class.name}: #{e.message}"
    exit 1
  end
when 'retrieve'
  begin
    result = hamburger.retrieve(cmd_opts[:identifier], cmd_opts[:keyname])
  rescue StandardError => e
    msg = "Failed to retrieve value for key #{cmd_opts[:keyname]} and hamburger #{cmd_opts[:identifier]}"
    puts "#{e.class.name}: #{msg}"
    exit 1
  end
  puts result
else
  fail "unknown subcommand #{cmd}"
end

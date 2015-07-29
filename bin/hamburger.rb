require_relative '../lib/hamburger'
require 'aws-sdk-core'
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
    Trollop.die "unknown subcommand #{cmd.inspect}"
  end

hamburger = HamburgerStore.new(table_name: cmd_opts[:table], key_id: cmd_opts[:kmsid], region: global_opts[:region])

case cmd
when 'store'
  hamburger.store(cmd_opts[:identifier], cmd_opts[:keyname], cmd_opts[:value])
when 'retrieve'
  result = hamburger.retrieve(cmd_opts[:identifier], cmd_opts[:keyname])
  puts result
else
  fail "unknown subcommand #{cmd}"
end

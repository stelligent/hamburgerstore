require 'aws-sdk-core'
require 'aws-sdk-resources'
require 'base64'
require 'hamburgerstore'

timestamp = Time.now.strftime '%Y%m%d%H%M%S'
key = "testkey#{timestamp}"
value = "testvalue#{timestamp}"
hamburger_identifier = "testinstance#{timestamp}"

Given(/^test data to use$/) do
  @hamburger_identifier = hamburger_identifier
  @key = key
  @value = value
  @empty_value = ''
end

Given(/^a region to operate in$/) do
  @region = ENV['region']
  @endpoint = ENV['endpoint']
  fail if @region.nil? && @endpoint.nil?
end

Given(/^a KMS key id to use$/) do
  @key_id = ENV['key_id']
  fail if @key_id.nil?
  @kms = Aws::KMS::Client.new region: @region
  resp = @kms.list_key_policies({
    key_id: @key_id,
    limit: 1
  }).policy_names
  expect(resp.size).to eq(1), "Did not find key with key ID '@key_id'"
end

Given(/^a DynamoDB table to use$/) do
  @table_name = ENV['table_name']
  fail if @table_name.nil?
  @ddb = Aws::DynamoDB::Resource.new region: @region
  @table = @ddb.table(@table_name)
end

When(/^I store a value in the keystore using the API$/) do
  hamburger = HamburgerStore.new(dynamo: @ddb, table_name: @table_name, key_id: @key_id, kms: @kms)
  hamburger.store(@hamburger_identifier, @key, @value)
end

When(/^I store an empty value in the keystore using the API$/) do
  hamburger = HamburgerStore.new(dynamo: @ddb, table_name: @table_name, key_id: @key_id, kms: @kms)
  hamburger.store(@hamburger_identifier, @key, @empty_value)
end

Then(/^I should see that encrypted data in the raw data store$/) do
  item = @table.get_item(key: { 'hamburger' => @hamburger_identifier }).item
  # we can't encrypt and get the same encrypted value, so just assert it exists and isn't the plaintext
  expect(item[@key]).to be
  expect(item[@key]).not_to eq @value
end

When(/^I retrieve a value from the keystore using the API$/) do
  hamburger = HamburgerStore.new(dynamo: @ddb, table_name: @table_name, key_id: @key_id, kms: @kms)
  hamburger.store(@hamburger_identifier, @key, @value)
  @result = hamburger.retrieve(@hamburger_identifier, @key)
end

When(/^I retrieve an empty value from the keystore using the API$/) do
  hamburger = HamburgerStore.new(dynamo: @ddb, table_name: @table_name, key_id: @key_id, kms: @kms)
  hamburger.store(@hamburger_identifier, @key, @empty_value)
  @result = hamburger.retrieve(@hamburger_identifier, @key)
end

Then(/^I should get that data back in plaintext$/) do
  expect(@result).to eq @value
end

Then(/^I should get that data back as an empty string$/) do
  expect(@result).to eq @empty_value
end

When(/^I retrieve all values from the data store using the API$/) do
  hamburger = HamburgerStore.new(dynamo: @ddb, table_name: @table_name, key_id: @key_id, kms: @kms)
  hamburger.store("#{@hamburger_identifier}_retrieveall", "#{@key}1", "#{@value}1")
  hamburger.store("#{@hamburger_identifier}_retrieveall", "#{@key}2", "#{@value}2")
  hamburger.store("#{@hamburger_identifier}_retrieveall", "#{@key}3", "#{@value}3")
  @result = hamburger.retrieve_all("#{@hamburger_identifier}_retrieveall")
end

Then(/^I should get back a hash of all the values$/) do
  expect(@result.size).to eq 4
  expect(@result["#{@key}1"]).to eq "#{@value}1"
  expect(@result["#{@key}2"]).to eq "#{@value}2"
  expect(@result["#{@key}3"]).to eq "#{@value}3"
end

When(/^I store a value in the keystore using the CLI$/) do
  @key = "#{@key}-cli"
  command = "hamburgerstore.rb store --table #{@table_name} --keyname #{@key} --identifier #{@hamburger_identifier} --kmsid #{@key_id} --value #{@value}-cli"
  `#{command}`
end

When(/^I store an empty value in the keystore using the CLI$/) do
  @key = "#{@key}-cli"
  escaped_value = '"' + @empty_value + '"'
  command = "hamburgerstore.rb store --table #{@table_name} --keyname #{@key} --identifier #{@hamburger_identifier} --kmsid #{@key_id} --value #{escaped_value}"
  `#{command}`
end

When(/^I retrieve a value from the keystore using the CLI$/) do
  @value = "#{@value}-cli"
  command = "hamburgerstore.rb store --table #{@table_name} --keyname #{@key} --identifier #{@hamburger_identifier} --kmsid #{@key_id} --value #{@value}"
  `#{command}`
  command = "hamburgerstore.rb retrieve --table #{@table_name} --keyname #{@key} --identifier #{@hamburger_identifier}"
  raw_result = `#{command}`
  @result = raw_result.strip
end

When(/^I retrieve an empty value from the keystore using the CLI$/) do
  escaped_value = '"' + @empty_value + '"'
  command = "hamburgerstore.rb store --table #{@table_name} --keyname #{@key} --identifier #{@hamburger_identifier} --kmsid #{@key_id} --value #{escaped_value}"
  `#{command}`
  command = "hamburgerstore.rb retrieve --table #{@table_name} --keyname #{@key} --identifier #{@hamburger_identifier}"
  raw_result = `#{command}`
  @result = raw_result.strip
end

Then(/^I should get an "([^"]*)" error that tells me that the value does not exist$/) do |exception_name|
  expect(@error.class.name).to be
  expect(@error.class.name).to eq exception_name
end

When(/^I try to retrieve a value for a non\-existent parameter name from the API$/) do
  begin
    hamburger = HamburgerStore.new(dynamo: @ddb, table_name: @table_name, key_id: @key_id, kms: @kms)
    @result = hamburger.retrieve(@hamburger_identifier, "thiskeydoesnotexist-#{rand 1_000_000}")
    fail('Expected an exception to be thrown')
  rescue HamburgerException => error
    @error = error
  end
end

When(/^I try to retrieve a value for a non\-existent Hamburger ID from the API$/) do
  begin
    hamburger = HamburgerStore.new(dynamo: @ddb, table_name: @table_name, key_id: @key_id, kms: @kms)
    @result = hamburger.retrieve('bogusIdentifier', @key)
    fail('Expected an exception to be thrown')
  rescue HamburgerException => error
    @error = error
  end
end

Then(/^I should recieve an nil value$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

When(/^I try to retrieve a value for a non\-existent parameter name from the CLI$/) do
  @key = "thiskeydoesnotexist-#{rand 1_000_000}"
  command = "hamburgerstore.rb retrieve --table #{@table_name} --keyname #{@key} --identifier #{@hamburger_identifier}"
  @success = system(command)
end

Then(/^I should recieve an empty string$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

When(/^I try to retrieve a value from a store that does not exist$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

Then(/^I should get an error that tells me that the store does not exist\.$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

When(/^I try to retrieve a value for a non\-existent Hamburger ID from the CLI$/) do
  @hamburger_identifier = "thiskeydoesnotexist-#{rand 1_000_000}"
  command = "hamburgerstore.rb retrieve --table #{@table_name} --keyname #{@key} --identifier #{@hamburger_identifier}"
  @success = system(command)
end

Then(/^I should get non-zero exit code$/) do
  fail 'Should have failed on non-existant key' if @success
end

Then(/^I should get an error in the commmand output that tells me that the value does not exist$/) do
  # pending # Write code here that turns the phrase above into concrete actions
end

# When(/^I retrieve all values from the data store using the CLI$/) do
#   pending # Write code here that turns the phrase above into concrete actions
# end

# Then(/^I should get back a JSON document of all the values$/) do
#   pending # Write code here that turns the phrase above into concrete actions
# end

# When(/^I try to retrieve a value using the wrong KMS key$/) do
#   pending # Write code here that turns the phrase above into concrete actions
# end

# Then(/^I should get an error that tells me I was using the wrong key\.$/) do
#   pending # Write code here that turns the phrase above into concrete actions
# end

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

Then(/^I should get that data back in plaintext$/) do
  expect(@result).to eq @value
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
  command = "ruby bin/hamburgerstore.rb store --table #{@table_name} --keyname #{@key} --identifier #{@hamburger_identifier} --kmsid #{@key_id} --value #{@value}-cli"
  `#{command}`
end

When(/^I retrieve a value from the keystore using the CLI$/) do
  @value = "#{@value}-cli"
  command = "ruby bin/hamburgerstore.rb store --table #{@table_name} --keyname #{@key} --identifier #{@hamburger_identifier} --kmsid #{@key_id} --value #{@value}"
  `#{command}`
  command = "ruby bin/hamburgerstore.rb retrieve --table #{@table_name} --keyname #{@key} --identifier #{@hamburger_identifier}"
  raw_result = `#{command}`
  @result = raw_result.strip
end

When(/^I retrieve all values from the data store using the CLI$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

Then(/^I should get back a JSON document of all the values$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

When(/^I try to retrieve a value using the wrong KMS key$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

Then(/^I should get an error that tells me I was using the wrong key\.$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

When(/^I try to retrieve a value that does not exist$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

Then(/^I should get an error that tells me that the value does not exist$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

When(/^I try to retrieve a value for a non\-existent parameter name from the API$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

Then(/^I should recieve an nil value$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

When(/^I try to retrieve a value for a non\-existent parameter name from the CLI$/) do
  pending # Write code here that turns the phrase above into concrete actions
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

require 'aws-sdk-core'
require 'aws-sdk-resources'
require_relative '../../lib/hamburger.rb'

Given(/^test data to use$/) do
  @key = "testkey#{Time.now.strftime '%Y%m%d%H%M%S'}"
  @value = "testvalue#{Time.now.strftime '%Y%m%d%H%M%S'}"
end

Given(/^a region to operate in$/) do
  @region = ENV['region']
  @endpoint = ENV['endpoint']
  fail if @region.nil? && @endpoint.nil?
end

Given(/^a KMS key id to use$/) do
  @key_id = ENV['key_id']
  fail if @key_id.nil?
end

Given(/^a DynamoDB table to use$/) do
  @table_name = ENV['table_name']
  fail if @table_name.nil?
  @ddb = Aws::DynamoDB::Resource.new region: @region
  @table = @ddb.table(@table_name)
end

When(/^I store a value in the keystore using the API$/) do
  hamburger = HamburgerStore.new(dynamo: @ddb, table_name: @table_name)
  hamburger.store('testinstance',  'testkey', 'testvalue')
end

Then(/^I should see that encrypted data in the raw data store$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

Then(/^I should see that data in the raw data store$/) do
  item = @table.get_item(key: { hamburger: 'testinstance' }).item
  fail 'no data returned' if item['testkey'].nil?
end

When(/^I retrieve a value from the keystore using the API$/) do
  hamburger = HamburgerStore.new(dynamo: @ddb, table_name: @table_name)
  hamburger.store('testinstance', 'testkey', 'testvalue')
  @result = hamburger.retrieve('testinstance',  'testkey')
end

Then(/^I should get that data back in plaintext$/) do
  expect(@result).to eq 'testvalue'
end

When(/^I retrieve all values from the data store using the API$/) do
  hamburger = HamburgerStore.new(dynamo: @ddb, table_name: @table_name)
  hamburger.store('testinstance_retrieveall', 'testkey1', 'testvalue1')
  hamburger.store('testinstance_retrieveall', 'testkey2', 'testvalue2')
  hamburger.store('testinstance_retrieveall', 'testkey3', 'testvalue3')
  @result = hamburger.retrieve_all('testinstance_retrieveall')
end

Then(/^I should get back a hash of all the values$/) do
  puts @result
  expect(@result.size).to eq 4
  expect(@result['testkey1']).to eq 'testvalue1'
  expect(@result['testkey2']).to eq 'testvalue2'
  expect(@result['testkey3']).to eq 'testvalue3'
end

When(/^I store a value in the keystore using the CLI$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

When(/^I retrieve a value from the keystore using the CLI$/) do
  pending # Write code here that turns the phrase above into concrete actions
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

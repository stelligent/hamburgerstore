require 'aws-sdk-core'
# require_relative '../../lib/hamburger.rb'

Given(/^test data to use$/) do
  @key = "testkey#{Time.now.strftime '%Y%m%d%H%M%S'}"
  @value = "testvalue#{Time.now.strftime '%Y%m%d%H%M%S'}"
end

Given(/^a region to operate in$/) do
  @region = ENV['region']
  fail if @region.nil?
end

Given(/^a KMS key id to use$/) do
  @key_id = ENV['key_id']
  fail if @key_id.nil?
end

Given(/^a DynamoDB table to use$/) do
  @table_name = ENV['table_name']
  fail if @table_name.nil?
end

When(/^I store a value in the keystore using the API$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

Then(/^I should see that encrypted data in the raw data store$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

When(/^I retrieve a value from the keystore using the API$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

Then(/^I should get that data back in plaintext$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

When(/^I retrieve all values from the data store using the API$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

Then(/^I should get back a hash of all the values$/) do
  pending # Write code here that turns the phrase above into concrete actions
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

require 'aws-sdk-resources'
require 'base64'

# Data store for pipeline instance metadata. Nothing to do with hamburgers. Sorry.
class HamburgerStore
  def encrypt(value)
    Base64.encode64(value)
  end

  def decrypt(value)
    Base64.decode64(value)
  end

  def initialize(params = {})
    @options = params
    # fail 'need to specify kms parameter' if @options[:kms].nil?
    if @options[:dynamo].nil?
      fail 'need to specify region' if @options[:region].nil?
      @ddb = Aws::DynamoDB::Resource.new region: @options[:region]
    else
      @ddb = @options[:dynamo]
    end
    fail 'need to specify table_name parameter' if @options[:table_name].nil?
    @table = @ddb.table(@options[:table_name])
  end

  def store(identifer, key, value)
    enc_key = encrypt(key)
    enc_value = encrypt(value)
    item = @table.get_item(key: { 'hamburger' => identifer }).item
    item = { 'hamburger' => identifer } if item.nil?
    item[enc_key] = enc_value
    @table.put_item(item: item, return_values: :ALL_OLD)
  end

  def retrieve(identifier, key)
    enc_key = encrypt(key)
    item = @table.get_item(key: { 'hamburger' => identifier }).item
    decrypt(item[enc_key])
  end

  def retrieve_all(identifier)
    encrypted_items = @table.get_item(key: { 'hamburger' => identifier }).item
    hamburger = encrypted_items.delete('hamburger')
    result = { 'hamburger' => hamburger }
    encrypted_items.each_pair do |key, value|
      dec_key = decrypt(key)
      dec_value = decrypt(value)
      result[dec_key] = dec_value
    end
    result
  end
end

# store a set of parameters (?)

# retrieve a single parameter

# retriever a parameter set

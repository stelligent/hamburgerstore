require 'aws-sdk-resources'
require 'base64'

# Data store for pipeline instance metadata. Nothing to do with hamburgers. Sorry.
class HamburgerStore
  def encrypt(value)
    value = ' ' if value.length < 1
    encrypted_value = @kms.encrypt(key_id: @key_id, plaintext: value).ciphertext_blob
    Base64.encode64(encrypted_value)
  end

  def decrypt(value)
    fail HamburgerKeyNotFoundInItemError, 'The key' if value.nil?
    encrypted_value = Base64.decode64(value)
    @kms.decrypt(ciphertext_blob: encrypted_value).plaintext.strip
  end

  def check_kms(options)
    # fail 'need to specify kms key_id parameter' if options[:key_id].nil?
    @key_id = options[:key_id]
    if options[:kms].nil?
      fail 'need to specify region' if options[:region].nil?
      @kms = Aws::KMS::Client.new region: options[:region]
    else
      @kms = options[:kms]
    end
  end

  def check_dynamo(options)
    if options[:dynamo].nil?
      fail 'need to specify region' if options[:region].nil?
      @ddb = Aws::DynamoDB::Resource.new region: options[:region]
    else
      @ddb = options[:dynamo]
    end
  end

  def initialize(options = {})
    check_kms(options)
    check_dynamo(options)

    fail 'need to specify table_name parameter' if options[:table_name].nil?
    @table = @ddb.table(options[:table_name])
  end

  def store(identifer, key, value)
    fail 'need to specify kms key_id parameter' if @key_id.nil?
    item = @table.get_item(key: { 'hamburger' => identifer }).item
    item = { 'hamburger' => identifer } if item.nil?
    item[key] = encrypt(value)
    @table.put_item(item: item, return_values: :ALL_OLD)
  end

  def ddb_get_item(identifier)
    item = @table.get_item(key: { 'hamburger' => identifier }).item
    if item.nil?
      fail HamburgerNoItemInTableError, "No values for '#{identifier}' found in table."
    end
    item
  end

  def retrieve(identifier, key)
    error = nil
    begin
      item = ddb_get_item(identifier)
    rescue StandardError => e
      error = e
    end
    if !error.nil? || item.nil? || item[key].nil?
      fail HamburgerKeyNotFoundInItemError, "The key '#{key}' was not found in '#{identifier}' hamburger store."
    end
    decrypt(item[key])
  end

  def retrieve_all(identifier)
    encrypted_items = ddb_get_item(identifier)
    hamburger = encrypted_items.delete('hamburger')
    result = { 'hamburger' => hamburger }
    encrypted_items.each_pair do |key, value|
      result[key] = decrypt(value)
    end
    result
  end
end

# Top level exception so we can catch our exceptions explicitly
class HamburgerException < StandardError
end

class HamburgerNoItemInTableError < HamburgerException
end

class HamburgerKeyNotFoundInItemError < HamburgerException
end

# store a set of parameters (?)

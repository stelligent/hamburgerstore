require 'aws-sdk-resources'
require 'base64'

# Data store for pipeline instance metadata. Nothing to do with hamburgers. Sorry.
class HamburgerStore
  def encrypt(value)
    encrypted_value = @kms.encrypt(key_id: @key_id, plaintext: value).ciphertext_blob
    Base64.encode64(encrypted_value)
  end

  def decrypt(value)
    encrypted_value = Base64.decode64(value)
    @kms.decrypt(ciphertext_blob: encrypted_value).plaintext
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

  def retrieve(identifier, key)
    item = @table.get_item(key: { 'hamburger' => identifier }).item
    fail "no values for #{identifier}" if item.nil?
    decrypt(item[key])
  end

  def retrieve_all(identifier)
    encrypted_items = @table.get_item(key: { 'hamburger' => identifier }).item
    hamburger = encrypted_items.delete('hamburger')
    result = { 'hamburger' => hamburger }
    encrypted_items.each_pair do |key, value|
      result[key] = decrypt(value)
    end
    result
  end
end

# store a set of parameters (?)

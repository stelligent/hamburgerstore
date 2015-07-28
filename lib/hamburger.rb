require 'aws-sdk-resources'

# Data store for pipeline instance metadata. Nothing to do with hamburgers. Sorry.
class HamburgerStore
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
    item = @table.get_item(key: { hamburger: identifer }).item
    item = { hamburger: identifer } if item.nil?
    item[key] = value
    @table.put_item(item: item, return_values: :ALL_OLD)
  end

  def retrieve(identifier, key)
    item = @table.get_item(key: { hamburger: identifier }).item
    item[key]
  end

  def retrieve_all(identifier)
    @table.get_item(key: { hamburger: identifier }).item
  end
end

# store a set of parameters (?)

# retrieve a single parameter

# retriever a parameter set

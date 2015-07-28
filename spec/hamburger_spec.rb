require 'base64'
require_relative '../lib/hamburger.rb'

# mock dynamo return value
class TableItem
  attr_accessor :item
  def initialize(value, data = {})
    @item = { 'hamburger' => value }
    @item.merge!(data)
  end
end

RSpec.describe 'HamburgerStore' do
  context 'Store Values' do
    it 'will call DynamoDB to store the value' do
      mock_ddb = double('Aws::DynamoDB::Resource')
      mock_table = double('Aws::DynamoDB::Table')
      table_name = 'nameOfTable'
      identifier = 'testInstance'
      expect(mock_ddb).to receive(:table).with(table_name) { mock_table }
      expect(mock_table).to receive(:get_item) { TableItem.new(identifier) }
      expect(mock_table).to receive(:put_item)
      hamburger = HamburgerStore.new dynamo: mock_ddb, table_name: table_name
      begin
        hamburger.store identifier, 'testkey', 'testvalue'
      rescue StandardError => e
        raise e
      end
    end
  end

  context 'Retrieve Values' do
    it 'will call DynamoDB to retrieve the value' do
      mock_ddb = double('Aws::DynamoDB::Resource')
      mock_table = double('Aws::DynamoDB::Table')
      table_name = 'nameOfTable'
      identifier = 'testInstance'
      expect(mock_ddb).to receive(:table).with(table_name) { mock_table }
      key = Base64.encode64('testKey')
      value = Base64.encode64('testValue')
      expect(mock_table).to receive(:get_item) { TableItem.new(identifier, key => value) }
      hamburger = HamburgerStore.new dynamo: mock_ddb, table_name: table_name
      begin
        result = hamburger.retrieve identifier, 'testKey'
        expect(result).to eq 'testValue'
      rescue StandardError => e
        raise e
      end
    end

    it 'can retrieve an entire set of values' do
      mock_ddb = double('Aws::DynamoDB::Resource')
      mock_table = double('Aws::DynamoDB::Table')
      table_name = 'nameOfTable'
      identifier = 'testInstance'
      expect(mock_ddb).to receive(:table).with(table_name) { mock_table }
      key = Base64.encode64('testKey')
      value = Base64.encode64('testValue')
      expect(mock_table).to receive(:get_item) { TableItem.new(identifier, key => value) }
      hamburger = HamburgerStore.new dynamo: mock_ddb, table_name: table_name
      begin
        result = hamburger.retrieve_all identifier
        expect(result.size).to eq 2
        expect(result['hamburger']).to eq identifier
        expect(result['testKey']).to eq 'testValue'
      rescue StandardError => e
        raise e
      end
    end
  end
end

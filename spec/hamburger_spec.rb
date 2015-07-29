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

# mock KMS return value
class KMSResult
  attr_accessor :ciphertext_blob, :plaintext
  def initialize(value)
    @ciphertext_blob = value
    @plaintext = value
  end
end

RSpec.describe 'HamburgerStore' do
  context 'Store Values' do
    it 'will call DynamoDB to store the value' do
      # mock out all the AWS stuff we're calling
      mock_ddb = double('Aws::DynamoDB::Resource')
      mock_table = double('Aws::DynamoDB::Table')
      mock_kms = double('Aws::KMS::Client')
      table_name = 'nameOfTable'
      identifier = 'testInstance'

      # set up our expectations for the mocks
      expect(mock_ddb).to receive(:table).with(table_name) { mock_table }
      expect(mock_table).to receive(:get_item) { TableItem.new(identifier) }
      expect(mock_table).to receive(:put_item)
      expect(mock_kms).to receive(:encrypt) { KMSResult.new('encrypted_data') }

      # okay let's do this
      hamburger = HamburgerStore.new dynamo: mock_ddb, table_name: table_name, key_id: 'irrelevant', kms: mock_kms
      begin
        hamburger.store identifier, 'testkey', 'testvalue'
      rescue StandardError => e
        raise e
      end
    end
  end

  context 'Retrieve Values' do
    it 'will call DynamoDB to retrieve the value' do
      # mock out all the AWS stuff we're calling
      mock_ddb = double('Aws::DynamoDB::Resource')
      mock_table = double('Aws::DynamoDB::Table')
      mock_kms = double('Aws::KMS::Client')
      table_name = 'nameOfTable'
      identifier = 'testInstance'
      expect(mock_ddb).to receive(:table).with(table_name) { mock_table }

      # set up our expectations for the mocks
      key = 'testkey'
      value = 'testValue'
      expect(mock_table).to receive(:get_item) { TableItem.new(identifier, key => value) }
      expect(mock_kms).to receive(:decrypt) { KMSResult.new(value) }

      # okay lets do this
      hamburger = HamburgerStore.new dynamo: mock_ddb, table_name: table_name, key_id: 'ignored', kms: mock_kms
      begin
        result = hamburger.retrieve identifier, key
        expect(result).to eq value
      rescue StandardError => e
        raise e
      end
    end

    it 'can retrieve an entire set of values' do
      # mock out all the AWS stuff we're calling
      mock_ddb = double('Aws::DynamoDB::Resource')
      mock_table = double('Aws::DynamoDB::Table')
      mock_kms = double('Aws::KMS::Client')
      table_name = 'nameOfTable'
      identifier = 'testInstance'

      # set expectations on mocks
      expect(mock_ddb).to receive(:table).with(table_name) { mock_table }
      key = 'testKey'
      value = 'testValue'
      expect(mock_table).to receive(:get_item) { TableItem.new(identifier, key => Base64.encode64(value)) }
      expect(mock_kms).to receive(:decrypt) { KMSResult.new(value) }

      # okay let's do this
      hamburger = HamburgerStore.new dynamo: mock_ddb, table_name: table_name, key_id: 'ignored', kms: mock_kms
      begin
        result = hamburger.retrieve_all identifier
        expect(result.size).to eq 2
        expect(result['hamburger']).to eq identifier
        expect(result[key]).to eq value
      rescue StandardError => e
        raise e
      end
    end
  end
end

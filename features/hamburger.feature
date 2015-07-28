Feature: Storing encrypted values
    In order for my pipeline to maintain state
    I want to be able to easily store and retrieve pipeline instance data 

    Background:
        Given a region to operate in
        And a DynamoDB table to use
        #And a KMS key id to use
        And test data to use

# Happy Path API

    Scenario: Store a value using the API
        When I store a value in the keystore using the API
        Then I should see that data in the raw data store

    Scenario: Retrieve a value using the API
        When I retrieve a value from the keystore using the API
        Then I should get that data back in plaintext

    Scenario: Retrieve all the values in the store using the API
        When I retrieve all values from the data store using the API
        Then I should get back a hash of all the values

# Happy Path API

    Scenario: Store a value using the CLI
        When I store a value in the keystore using the CLI
        Then I should see that encrypted data in the raw data store

    Scenario: Retrieve a value using the CLI
        When I retrieve a value from the keystore using the CLI
        Then I should get that data back in plaintext

    Scenario: Retrieve all the values in the store using the CLI
        When I retrieve all values from the data store using the CLI
        Then I should get back a JSON document of all the values

# Sad Path

    Scenario: Bad key used to retrieve value
        When I try to retrieve a value using the wrong KMS key
        Then I should get an error that tells me I was using the wrong key.

    Scenario: Value does not exist
        When I try to retrieve a value that does not exist
        Then I should get an error that tells me that the value does not exist

    Scenario: Name does not exist from an API call
        When I try to retrieve a value for a non-existent parameter name from the API
        Then I should recieve an nil value

    Scenario: Name does not exist from a CLI call
        When I try to retrieve a value for a non-existent parameter name from the CLI
        Then I should recieve an empty string

    Scenario: Data store does not exist
        When I try to retrieve a value from a store that does not exist
        Then I should get an error that tells me that the store does not exist.



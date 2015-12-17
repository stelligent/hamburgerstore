# hamburgerstore :hamburger:

Hamburger Store is an easy, lightweight way to store data about your pipeline runs. As you go through your pipeline, you're going to produce a lot of information that's relevant to your pipeline instance, and having to store that in a text file or pass parameters between jobs can get very unwieldy very quickly. Hamburger Store utilizes two AWS services (Amazon DynamoDB and AWS Key Management Service) to provide an easy way to securely store the data your pipeline needs, without the bother of having to set it up yourself.

# description :hamburger:

Hamburger Store keeps all the values in a DynamoDB table. Hamburger Store follows the Amazon best practice of "always encrypt data at rest"; all values are encrypted using KMS, so you can safely secure sensitive data.  All calls require specifying the data store name, and the KMS key to use to encrypt with. Most of the time you'll probably just be looking up single values, but functionality is provided to dump the entire data store so it can be viewed easily.

# usage :hamburger:

**cli**

Shell scripts are the most common building blocks of pipeline jobs, so using the CLI is probably the easiest way to store and retrieve values. You can use the following commands to manipulate your data store:

    ruby bin/hamburger.rb store --table hamburger-table --identifier "mypipeline" --keyname "yourkey" --kmsid "your-kms-key-id" --value "testvalue2"
    ruby bin/hamburger.rb retrieve --table hamburger-table --identifier "mypipeline" --keyname "yourkey"
    # not implemented yet...
    ruby bin/hamburger.rb retrieve_all --table hamburger-table --identifier "mypipeline"

**api**

If your pipeline scripts happen to be written in Ruby, you can just call HamburgerStore APIs directly, and get a bit more flexibility:

    hamburger = HamburgerStore.new(table_name: "hamburger_table", key_id: "your-kms-key-id)
    hamburger.store("mypipeline", "yourkey", "testvalue2")
    result_string = hamburger.retrieve("mypipeline", "yourkey")
    result_hash = hamburger.retrieve_all("mypipeline")

# developement

If you want to develop new features or fix bugs in Hamgburger Store, awesome! You'll probably want to know how to run the tests, though, so here's how:

* First, you'll need to set up a KMS key. Since KMS keys cost money and cannot be deleted after creation, you'll probably want to [do that part manually](https://console.aws.amazon.com/iam/home?encryptionKeys/#encryptionKeys/us-east-1).
* After your KMS key is created, you'll want to create a DynamoDB Table to store your values in. We've provided a simple CloudFormation template for that, which you can run with the following command:

    aws cloudformation create-stack --stack-name "hamburgerstore" --template-body file://config/dynamo.json

After which, you'll need to lookup the name of your DynamoDB table and store that value for later.

    export table_name=`aws cloudformation describe-stacks --stack-name hamburgerstore --query Stacks[*].Outputs[*].OutputValue --output text`

    rspec
    cucumber region="your-region" table_name="$table_name" key_id="your-kms-key-id"

# feedback :hamburger:

Hamburger Store is one of of several Stelligent open source projects that we built to make our lives easier, and hopefully it'll make your life easier too! If you have any feedback/request/bug reports, feel free to open a github issue. Alternatively, you can shoot us and email or hit us up on twitter.

* info@stelligent.com
* [@stelligent](https://twitter.com/stelligent)

# license :hamburger:

Copyright (c) 2015 Stelligent Systems LLC

MIT LICENSE

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


# This Readme

This readme covers the steps to testing and making changes to the Wafris RB client itself and not the installation and use of Wafris in Rails.

## For local development

1. Install rerun: `gem install rerun`

2. Navigate to the `test/dummy` directory

3. From `test/dummy` run 

`WAFRIS_API_KEY='wafris-client-test-api-key' rerun -d ../../ 'rails server -p 3333'`

This will relaunch the Rails app whenever a file changes in the wafris-rb gem.

# Testing API Key

As this is a client for the Wafris API, it can be tricky to develop against. Our recommendation is to use the test API key `wafris-client-test-api-key` for development. This key is loaded with the "Wafris Client Test" ruleset on the Wafris Hub. 

This will let you use the production (default) Downsync and Upsync endpoints without needing to set up a local development version of the Wafris Hub application.

# Testing Endpoints

Use the Wafris Client Tests - https://github.com/Wafris/wafris-client-tests to test the endpoints. 

# Dummy application should be configured to:

- Allow `GET` and `POST` requests `/`
- Allow `example.com` and `blocked.com` hosts in development 



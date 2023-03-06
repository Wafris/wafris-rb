# Redis Testing

## Context

This directory holds utilties for testing the speed and storage use of different Redis configurations.

## 1. Generating a new lua Data file with Faker
Call `bundle exec ruby ip_data_generator.rb INTEGER` to generate a new file of ip_addresses and timestamps

## 2. Execute the generated Lua script in Redis
`redis-cli --eval ./INTEGER_data_load.lua`

## 3. Query Suite
`TBD`


# This Readme

This readme covers the steps to testing and making changes to the Wafris RB client itself and not the installation and use of Wafris in Rails.

## For local development

1. Install rerun: `gem install rerun`

2. Remove any Wafris environment variables: `bash ./remove-env-vars.sh`

3. Set target environment variables: `source ./set-dev-env-vars.sh`

3. From `test/dummy` run `rerun -d ../../ 'rails server -p 3333'` - this will relaunch the Rails app whenever a file changes in the wafris-rb gem.


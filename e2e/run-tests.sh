#!/bin/bash

tag=$1

export COMMON_CONFIG_FILE="./env/common.env"

# Run tests. Run poste2etest script upon tests fail due to Cucumber failures.
npm run e2etest -- --profile $tag
exit_code=$?

if [ $exit_code -eq 1 ]; then
  npm run poste2etest
fi

exit $exit_code

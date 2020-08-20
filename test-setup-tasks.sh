#!/bin/bash

set

echo $HEROKU_TEST_RUN_COMMIT_VERSION > COMMIT

gem install rubocop

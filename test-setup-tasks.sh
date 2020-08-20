#!/bin/bash

echo $HEROKU_TEST_RUN_COMMIT_VERSION > COMMIT
echo $HEROKU_TEST_RUN_NUMBER > BUILDID

pwd
ls -al

gem install rubocop

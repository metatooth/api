#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: functional.h [URL]"
    echo "       Run functional tests against a URL"
    echo "       For example, ./functional.sh http://localhost:9393/v1"
    exit
fi

function check_response () {
    if [[ $1 -eq 200 ]]
    then
        echo "Success"
        jq . response.json
    else
        echo "Failure"
        exit
    fi
}

URL=$1

echo "SIGN UP USER MANAGER"
STATUS=$(curl --write-out "%{http_code}\n" -d @user-manager-signin.json --output response.json -H 'Content-Type: application/json' $URL/signup)
echo $STATUS
cat response.json

echo "SIGN UP ADMIN"
STATUS=$(curl --write-out "%{http_code}\n" -d @admin-signin.json --output response.json -H 'Content-Type: application/json' $URL/signup)
echo $STATUS
cat response.json


echo "SIGN IN USER MANAGER"
STATUS=$(curl --write-out "%{http_code}\n" -d @user-manager-signin.json --output response.json -H 'Content-Type: application/json' $URL/signin)
echo $STATUS
USER_MANAGER_ACCESS_TOKEN=`cat response.json`

echo "SIGN IN ADMIN"
STATUS=$(curl --write-out "%{http_code}\n" -d @admin-signin.json --output response.json -H 'Content-Type: application/json' $URL/signin)
echo $STATUS
ADMIN_ACCESS_TOKEN=`cat response.json`

echo "GET USERS as USER MANAGER"
STATUS=$(curl --write-out "%{http_code}\n" --output response.json -H 'Authorization: Bearer '$USER_MANAGER_ACCESS_TOKEN -H 'Content-Type: application/json' $URL/users)
check_response STATUS

rm response.json
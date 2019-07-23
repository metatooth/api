#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: functional.h [URL]"
    echo "       Run functional tests against a URL"
    echo "       For example, ./functional.sh http://localhost:9393/v1"
    exit
fi

function check_response () {
    if [[ $1 -eq $2 ]]
    then
        echo "Success"
    else
        echo "Failure"
        exit
    fi
}

function check_200_response () {
    check_response $1 200
}

function check_401_response () {
    check_response $1 401
}

URL=$1

TIMESTAMP=`date +%s`

echo "SIGN UP USER"
STATUS=$(curl --write-out "%{http_code}\n" -d '{ "username": "User'$TIMESTAMP'", "password": "foobar" }' --silent --output response.json -H 'Content-Type: application/json' $URL/signup)
USER_ID=`jq -s -r .[0].id response.json`
echo "User ID "$USER_ID

echo "SIGN UP USER MANAGER"
STATUS=$(curl --write-out "%{http_code}\n" -d '{ "username": "UserManager", "password": "foobar" }' --silent --output response.json -H 'Content-Type: application/json' $URL/signup)

echo "SIGN UP ADMIN"
STATUS=$(curl --write-out "%{http_code}\n" -d '{ "username": "Admin", "password": "foobar" }' --silent --output response.json -H 'Content-Type: application/json' $URL/signup)

echo "=== TEST SIGN IN ON THIRD ATTEMPT ==="

echo "SIGN IN USER Attempt 1"
STATUS=$(curl --write-out "%{http_code}\n" -d '{ "username": "User'$TIMESTAMP'", "password": "blat" }' --silent --output response.json -H 'Content-Type: application/json' $URL/signin)
check_401_response $STATUS

echo "SIGN IN USER Attempt 2"
STATUS=$(curl --write-out "%{http_code}\n" -d '{ "username": "User'$TIMESTAMP'", "password": "blarg" }' --silent --output response.json -H 'Content-Type: application/json' $URL/signin)
check_401_response $STATUS

echo "SIGN IN USER Attempt 3"
STATUS=$(curl --write-out "%{http_code}\n" -d '{ "username": "User'$TIMESTAMP'", "password": "foobar" }' --silent --output response.json -H 'Content-Type: application/json' $URL/signin)
check_200_response $STATUS
USER_ACCESS_TOKEN=`cat response.json`
echo "Token $USER_ACCESS_TOKEN"

echo "== TEST USER LOCKOUT =="

echo "SIGN IN USER Attempt 1"
STATUS=$(curl --write-out "%{http_code}\n" -d '{ "username": "User'$TIMESTAMP'", "password": "blah" }' --silent --output response.json -H 'Content-Type: application/json' $URL/signin)
check_401_response $STATUS

echo "SIGN IN USER Attempt 2"
STATUS=$(curl --write-out "%{http_code}\n" -d '{ "username": "User'$TIMESTAMP'", "password": "blarg" }' --silent --output response.json -H 'Content-Type: application/json' $URL/signin)
check_401_response $STATUS

echo "SIGN IN USER Attempt 3"
STATUS=$(curl --write-out "%{http_code}\n" -d '{ "username": "User'$TIMESTAMP'", "password": "blech" }' --silent --output response.json -H 'Content-Type: application/json' $URL/signin)
check_401_response $STATUS

echo "SIGN IN USER Attempt 4"
STATUS=$(curl --write-out "%{http_code}\n" -d '{ "username": "User'$TIMESTAMP'", "password": "foobar" }' --silent --output response.json -H 'Content-Type: application/json' $URL/signin)
check_401_response $STATUS

echo "-- RESET USER ATTEMPTS by USER MANAGER --"

echo "SIGN IN USER MANAGER"
STATUS=$(curl --write-out "%{http_code}\n" -d '{ "username": "UserManager", "password": "foobar" }' --silent --output response.json -H 'Content-Type: application/json' $URL/signin)
echo $STATUS
USER_MANAGER_ACCESS_TOKEN=`cat response.json`
echo "Token "$USER_MANAGER_ACCESS_TOKEN

echo "PUT USER "$USER_ID" as USER MANAGER"
STATUS=$(curl --write-out "%{http_code}\n" -d '{ "failed_attempts" : "0" }' --silent --output response.json -X PUT -H 'Authorization: Bearer '$USER_MANAGER_ACCESS_TOKEN -H 'Content-Type: application/json' $URL/users/$USER_ID)
check_200_response $STATUS

echo "SIGN IN USER Attempt 1"
STATUS=$(curl --write-out "%{http_code}\n" -d '{ "username": "User'$TIMESTAMP'", "password": "foobar" }' --silent --output response.json -H 'Content-Type: application/json' $URL/signin)
check_200_response $STATUS
USER_ACCESS_TOKEN=`cat response.json`
echo "Token $USER_ACCESS_TOKEN"

echo "=== TEST DELETE USER ==="

echo "SIGN IN ADMIN"
STATUS=$(curl --write-out "%{http_code}\n" -d '{ "username": "Admin", "password": "foobar" }' --silent --output response.json -H 'Content-Type: application/json' $URL/signin)
check_200_response $STATUS
ADMIN_ACCESS_TOKEN=`cat response.json`
echo "Token "$ADMIN_ACCESS_TOKEN

echo "DELETE USER "$USER_ID" as ADMIN"
STATUS=$(curl --write-out "%{http_code}\n" --silent --output response.json -x DELETE -H 'Authorization: Bearer '$ADMIN_ACCESS_TOKEN -H 'Content-Type: application/json' $URL/users/$USER_ID)
echo $STATUS
cat response.json
check_200_response STATUS

rm response.json
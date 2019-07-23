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

echo ""
echo "=== TEST CREATION OF ADMIN USER ==="

echo "Signup Admin"
STATUS=$(curl $URL/signup -d '{ "username": "Admin'$TIMESTAMP'", "password": "foobar" }' -H 'Content-Type: application/json' --write-out "%{http_code}\n" --silent --output response.json)
check_200_response $STATUS
ADMIN_ID=`jq -s -r .[0].id response.json`
echo "Admin ID "$ADMIN_ID

echo "Signin Admin"
STATUS=$(curl $URL/signin -d '{ "username": "Admin'$TIMESTAMP'", "password": "foobar" }' -H 'Content-Type: application/json' --write-out "%{http_code}\n" --silent --output response.json)
check_200_response $STATUS
ADMIN_ACCESS_TOKEN=`cat response.json`
echo "Token $ADMIN_ACCESS_TOKEN"

echo ""
echo "=== TEST CREATION OF USER ==="

echo "Signup User"
STATUS=$(curl $URL/signup -d '{ "username": "User'$TIMESTAMP'", "password": "foobat" }' -H 'Content-Type: application/json' --write-out "%{http_code}\n" --silent --output response.json)
check_200_response $STATUS
USER_ID=`jq -s -r .[0].id response.json`
echo "User ID "$USER_ID

echo "Signin User"
STATUS=$(curl $URL/signin -d '{ "username": "User'$TIMESTAMP'", "password": "foobat" }' -H 'Content-Type: application/json' --write-out "%{http_code}\n" --silent --output response.json)
check_200_response $STATUS
USER_ACCESS_TOKEN=`cat response.json`
echo "Token $USER_ACCESS_TOKEN"

echo ""
echo "=== TEST CREATION OF USER MANAGER ==="

echo "Signup UserManager"
STATUS=$(curl $URL/signup -d '{ "username": "UserManager'$TIMESTAMP'", "password": "foobaz" }' -H 'Content-Type: application/json' --write-out "%{http_code}\n" --silent --output response.json)
check_200_response $STATUS
USER_MANAGER_ID=`jq -s -r .[0].id response.json`
echo "User Manger ID "$USER_MANAGER_ID

echo "Signin UserManager"
STATUS=$(curl $URL/signin -d '{ "username": "UserManager'$TIMESTAMP'", "password": "foobaz" }' -H 'Content-Type: application/json' --write-out "%{http_code}\n" --silent --output response.json)
check_200_response $STATUS
USER_MANAGER_ACCESS_TOKEN=`cat response.json`
echo "Token $USER_MANAGER_ACCESS_TOKEN"

echo "PUT User $USER_MANAGER_ID to UserManager role as Admin"
STATUS=$(curl -X PUT $URL/users/$USER_MANAGER_ID -d '{ "type": "UserManager" }' -H 'Authorization: Bearer '$ADMIN_ACCESS_TOKEN -H 'Content-Type: application/json' --write-out "%{http_code}\n" --silent --output response.json)
check_200_response $STATUS

echo "=== TEST SIGN IN ON THIRD ATTEMPT ==="

echo "SIGN IN USER Attempt 1"
STATUS=$(curl $URL/signin -d '{ "username": "User'$TIMESTAMP'", "password": "blat" }' -H 'Content-Type: application/json' --write-out "%{http_code}\n" --silent --output response.json)
check_401_response $STATUS

echo "SIGN IN USER Attempt 2"
STATUS=$(curl $URL/signin -d '{ "username": "User'$TIMESTAMP'", "password": "blarg" }' -H 'Content-Type: application/json' --write-out "%{http_code}\n" --silent --output response.json)
check_401_response $STATUS

echo "SIGN IN USER Attempt 3"
STATUS=$(curl $URL/signin -d '{ "username": "User'$TIMESTAMP'", "password": "foobat" }' -H 'Content-Type: application/json' --write-out "%{http_code}\n" --silent --output response.json)
check_200_response $STATUS
USER_ACCESS_TOKEN=`cat response.json`
echo "Token $USER_ACCESS_TOKEN"

echo "=== TEST USER LOCKOUT ==="

echo "SIGN IN USER Attempt 1"
STATUS=$(curl $URL/signin -d '{ "username": "User'$TIMESTAMP'", "password": "blah" }' -H 'Content-Type: application/json' --write-out "%{http_code}\n" --silent --output response.json)
check_401_response $STATUS

echo "SIGN IN USER Attempt 2"
STATUS=$(curl $URL/signin -d '{ "username": "User'$TIMESTAMP'", "password": "blarg" }' -H 'Content-Type: application/json' --write-out "%{http_code}\n" --silent --output response.json)
check_401_response $STATUS

echo "SIGN IN USER Attempt 3"
STATUS=$(curl $URL/signin -d '{ "username": "User'$TIMESTAMP'", "password": "blech" }' -H 'Content-Type: application/json' --write-out "%{http_code}\n" --silent --output response.json)
check_401_response $STATUS

echo "SIGN IN USER Attempt 4"
STATUS=$(curl $URL/signin -d '{ "username": "User'$TIMESTAMP'", "password": "foobat" }' -H 'Content-Type: application/json' --write-out "%{http_code}\n" --silent --output response.json)
check_401_response $STATUS

echo "-- RESET USER ATTEMPTS by USER MANAGER --"

echo "PUT USER "$USER_ID" to Zero Attempts as USER MANAGER"
STATUS=$(curl -X PUT $URL/users/$USER_ID -d '{ "failed_attempts" : "0" }' -H 'Authorization: Bearer '$USER_MANAGER_ACCESS_TOKEN -H 'Content-Type: application/json' --write-out "%{http_code}\n" --silent --output response.json)
check_200_response $STATUS

echo "SIGN IN USER Attempt 1"
STATUS=$(curl $URL/signin -d '{ "username": "User'$TIMESTAMP'", "password": "foobat" }' -H 'Content-Type: application/json' --write-out "%{http_code}\n" --silent --output response.json)
check_200_response $STATUS
USER_ACCESS_TOKEN=`cat response.json`
echo "Token $USER_ACCESS_TOKEN"

echo "=== TEST DELETE USER ==="

echo "DELETE USER "$USER_ID" as Admin"
STATUS=$(curl -X DELETE $URL/users/$USER_ID -H 'Authorization: Bearer '$ADMIN_ACCESS_TOKEN -H 'Content-Type: application/json' --write-out "%{http_code}\n" --silent --output response.json)
check_200_response STATUS

echo "=== TEST DELETE USER MANAGER ==="

echo "DELETE USER "$USER_MANAGER_ID" as Admin"
STATUS=$(curl -X DELETE $URL/users/$USER_MANAGER_ID -H 'Authorization: Bearer '$ADMIN_ACCESS_TOKEN -H 'Content-Type: application/json' --write-out "%{http_code}\n" --silent --output response.json)
check_200_response STATUS

echo "=== TEST DELETE ADMIN ==="

echo "DELETE USER "$ADMIN_ID" as Admin"
STATUS=$(curl -X DELETE $URL/users/$ADMIN_ID -H 'Authorization: Bearer '$ADMIN_ACCESS_TOKEN -H 'Content-Type: application/json' --write-out "%{http_code}\n" --silent --output response.json)
check_401_response STATUS


rm response.json
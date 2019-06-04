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


echo "SIGN UP USER"
STATUS=$(curl --write-out "%{http_code}\n" -d @user-signin.json --output response.json -H 'Content-Type: application/json' $URL/signup)
echo $STATUS
cat response.json

echo "SIGN UP USER MANAGER"
STATUS=$(curl --write-out "%{http_code}\n" -d @user-manager-signin.json --output response.json -H 'Content-Type: application/json' $URL/signup)
echo $STATUS
cat response.json

echo "SIGN UP ADMIN"
STATUS=$(curl --write-out "%{http_code}\n" -d @admin-signin.json --output response.json -H 'Content-Type: application/json' $URL/signup)
echo $STATUS
cat response.json


echo "SIGN IN USER"
STATUS=$(curl --write-out "%{http_code}\n" -d @user-signin.json --output response.json -c user-cookie.txt -H 'Content-Type: application/json' $URL/signin)
echo $STATUS

echo "SIGN IN USER MANAGER"
STATUS=$(curl --write-out "%{http_code}\n" -d @user-manager-signin.json --output response.json -c user-manager-cookie.txt -H 'Content-Type: application/json' $URL/signin)
echo $STATUS

echo "SIGN IN ADMIN"
STATUS=$(curl --write-out "%{http_code}\n" -d @admin-signin.json --output response.json -c admin-cookie.txt -H 'Content-Type: application/json' $URL/signin)
echo $STATUS


echo "GET MEALS as USER"
STATUS=$(curl --write-out "%{http_code}\n" --silent --output response.json -b user-cookie.txt -v $URL/meals)
check_response STATUS

echo "POST MEALS as USER"
STATUS=$(curl --write-out "%{http_code}\n" -d @create.json --output response.json -b user-cookie.txt -H 'Content-Type: application/json' $URL/meals)
check_response STATUS

ID=`jq -s -r .[0].id response.json`

echo "GET MEAL $ID as USER"
STATUS=$(curl --write-out "%{http_code}\n" --output response.json -b user-cookie.txt -H 'Content-Type: application/json' -v $URL/meals/$ID)
check_response STATUS

echo "PUT MEAL $ID as USER"
STATUS=$(curl --write-out "%{http_code}\n" -d @update.json --output response.json -b user-cookie.txt -X PUT -H 'Content-Type: application/json' $URL/meals/$ID)
check_response STATUS

echo "DELETE MEAL $ID as USER"
STATUS=$(curl --write-out "%{http_code}\n" --output response.json -b user-cookie.txt -X DELETE -H 'Content-Type: application/json' $URL/meals/$ID)
check_response STATUS

echo "GET USERS as USER"
STATUS=$(curl --write-out "%{http_code}\n" --output response.json -b user-cookie.txt -H 'Content-Type: application/json' $URL/users)
check_response STATUS

echo "GET USERS as USER MANAGER"
STATUS=$(curl --write-out "%{http_code}\n" --output response.json -b user-manager-cookie.txt -H 'Content-Type: application/json' $URL/users)
check_response STATUS

rm user-cookie.txt
rm user-manager-cookie.txt
rm admin-cookie.txt
rm response.json
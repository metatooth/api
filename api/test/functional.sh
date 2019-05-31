#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: functional.h [URL]"
    echo "       Run functional tests against a URL"
    echo "       For example, functional.sh http://localhost:9393/v1"
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


echo "SIGN UP"
STATUS=$(curl --write-out "%{http_code}\n" -d @tester-signin.json --output response.json -H 'Content-Type: application/json' $URL/signup)
echo $STATUS
cat response.json


echo "SIGN IN"
STATUS=$(curl --write-out "%{http_code}\n" -d @tester-signin.json --output response.json -c cookie.txt -H 'Content-Type: application/json' $URL/signin)
echo $STATUS

echo "GET MEALS"
STATUS=$(curl --write-out "%{http_code}\n" --silent --output response.json -b cookie.txt -v $URL/meals)
check_response STATUS

echo "POST MEALS"
STATUS=$(curl --write-out "%{http_code}\n" -d @create.json --output response.json -b cookie.txt -H 'Content-Type: application/json' $URL/meals)
check_response STATUS

ID=`jq -s -r .[0].id response.json`

echo "GET MEAL $ID"
STATUS=$(curl --write-out "%{http_code}\n" --output response.json -b cookie.txt -H 'Content-Type: application/json' -v $URL/meals/$ID)
check_response STATUS

echo "PUT MEAL $ID"
STATUS=$(curl --write-out "%{http_code}\n" -d @update.json --output response.json -b cookie.txt -X PUT -H 'Content-Type: application/json' $URL/meals/$ID)
check_response STATUS

echo "DELETE MEAL $ID"
STATUS=$(curl --write-out "%{http_code}\n" --output response.json -b cookie.txt -X DELETE -H 'Content-Type: application/json' $URL/meals/$ID)
check_response STATUS

rm cookie.txt
rm response.json
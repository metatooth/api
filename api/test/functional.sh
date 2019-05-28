#!/bin/bash

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

URL=http://localhost:5000

STATUS=$(curl --write-out "%{http_code}\n" --silent --output response.json -v $URL/v1/meals)
check_response STATUS

STATUS=$(curl --write-out "%{http_code}\n" -d @create.json --output response.json -H 'Content-Type: application/json' $URL/v1/meals)
check_response STATUS

ID=`jq -s -r .[0].id response.json`

STATUS=$(curl --write-out "%{http_code}\n" --output response.json -H 'Content-Type: application/json' -v $URL/v1/meals/$ID)
check_response STATUS

STATUS=$(curl --write-out "%{http_code}\n" -d @update.json --output response.json -X PUT -H 'Content-Type: application/json' $URL/v1/meals/$ID)
check_response STATUS

STATUS=$(curl --write-out "%{http_code}\n" --output response.json -X DELETE -H 'Content-Type: application/json' $URL/v1/meals/$ID)
check_response STATUS


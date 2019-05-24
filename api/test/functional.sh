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

STATUS=$(curl --write-out "%{http_code}\n" --silent --output response.json -v http://localhost:9393/v1/meals)
check_response STATUS

STATUS=$(curl --write-out "%{http_code}\n" -d @create.json --output response.json -H 'Content-Type: application/json' http://localhost:9393/v1/meals)
check_response STATUS

ID=`jq -s -r .[0].id response.json`

STATUS=$(curl --write-out "%{http_code}\n" --output response.json -H 'Content-Type: application/json' -v http://localhost:9393/v1/meals/$ID)
check_response STATUS

STATUS=$(curl --write-out "%{http_code}\n" -d update.json -X PUT -H 'Content-Type: application/json' http://localhost:9393/v1/meals/$ID)
check_response STATUS

STATUS=$(curl --write-out "%{http_code}\n" -X DELETE -H 'Content-Type: application/json' http://localhost:9393/v1/meals/$ID)
check_response STATUS


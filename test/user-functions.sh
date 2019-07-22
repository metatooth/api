#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: user-functions.h [URL]"
    echo "       Run functional tests against a URL"
    echo "       For example, ./user-functions.sh http://localhost:9393/v1"
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
STATUS=$(curl --write-out "%{http_code}\n" -d @user-signin.json --silent --output response.json -H 'Content-Type: application/json' $URL/signup)
echo $STATUS
cat response.json

echo "SIGN IN USER"
STATUS=$(curl --write-out "%{http_code}\n" -d @user-signin.json --silent --output response.json -H 'Content-Type: application/json' $URL/signin)
echo $STATUS
USER_ACCESS_TOKEN=`cat response.json`

echo "GET TASKS as USER"
STATUS=$(curl --write-out "%{http_code}\n" --silent --output response.json -H 'Authorization: Bearer '$USER_ACCESS_TOKEN -H 'Content-Type: application/json' $URL/tasks)
echo $STATUS
check_response STATUS

echo "POST TASKS as USER"
STATUS=$(curl --write-out "%{http_code}\n" -d @create.json --silent --output response.json -H 'Authorization: Bearer '$USER_ACCESS_TOKEN -H 'Content-Type: application/json' $URL/tasks)
check_response STATUS

TASK_ID=`jq -s -r .[0].id response.json`

echo "GET TASK $TASK_ID as USER"
STATUS=$(curl --write-out "%{http_code}\n" --silent --output response.json -H 'Authorization: Bearer '$USER_ACCESS_TOKEN -H 'Content-Type: application/json' -v $URL/tasks/$TASK_ID)
check_response STATUS

echo "PUT TASK $TASK_ID as USER"
STATUS=$(curl --write-out "%{http_code}\n" -d @update.json --silent --output response.json -X PUT -H 'Authorization: Bearer '$USER_ACCESS_TOKEN -H 'Content-Type: application/json' $URL/tasks/$TASK_ID)
check_response STATUS

echo "GET TASK $TASK_ID NOTES as USER"
STATUS=$(curl --write-out "%{http_code}\n" --silent --output response.json -H 'Authorization: Bearer '$USER_ACCESS_TOKEN -H 'Content-Type: application/json' -v $URL/tasks/$TASK_ID/notes)
check_response STATUS

echo "POST TASK $TASK_ID NOTES as USER"
STATUS=$(curl --write-out "%{http_code}\n" -d '{ "text" : "no man is an island" }' --silent --output response.json -H 'Authorization: Bearer '$USER_ACCESS_TOKEN -H 'Content-Type: application/json' $URL/tasks/$TASK_ID/notes)
check_response STATUS
NOTE_ID=`jq -s -r .[0].id response.json`

echo "POST TASK $TASK_ID NOTES as USER"
STATUS=$(curl --write-out "%{http_code}\n" -d '{ "text" : "white pepper" }' --silent --output response.json -H 'Authorization: Bearer '$USER_ACCESS_TOKEN -H 'Content-Type: application/json' $URL/tasks/$TASK_ID/notes)
check_response STATUS

echo "POST TASK $TASK_ID NOTES as USER"
STATUS=$(curl --write-out "%{http_code}\n" -d '{ "text" : "ice cream" }' --silent --output response.json -H 'Authorization: Bearer '$USER_ACCESS_TOKEN -H 'Content-Type: application/json' $URL/tasks/$TASK_ID/notes)
check_response STATUS

echo "PUT TASK $TASK_ID NOTE $NOTE_ID as USER"
STATUS=$(curl --write-out "%{http_code}\n" -d '{ "text" : "foobar" }' --silent --output response.json -X PUT -H 'Authorization: Bearer '$USER_ACCESS_TOKEN -H 'Content-Type: application/json' $URL/tasks/$TASK_ID/notes/$NOTE_ID)
check_response STATUS

echo "GET TASK $TASK_ID NOTES as USER"
STATUS=$(curl --write-out "%{http_code}\n" --silent --output response.json -H 'Authorization: Bearer '$USER_ACCESS_TOKEN -H 'Content-Type: application/json' -v $URL/tasks/$TASK_ID/notes)
check_response STATUS

echo "DELETE TASK $TASK_ID NOTE $NOTE_ID as USER"
STATUS=$(curl --write-out "%{http_code}\n" --silent --output response.json -X DELETE -H 'Authorization: Bearer '$USER_ACCESS_TOKEN -H 'Content-Type: application/json' $URL/tasks/$TASK_ID/notes/$NOTE_ID)
check_response STATUS

echo "GET TASK $TASK_ID NOTES as USER"
STATUS=$(curl --write-out "%{http_code}\n" --silent --output response.json -H 'Authorization: Bearer '$USER_ACCESS_TOKEN -H 'Content-Type: application/json' -v $URL/tasks/$TASK_ID/notes)
check_response STATUS

echo "DELETE TASK $TASK_ID as USER"
STATUS=$(curl --write-out "%{http_code}\n" --silent --output response.json -X DELETE -H 'Authorization: Bearer '$USER_ACCESS_TOKEN -H 'Content-Type: application/json' $URL/tasks/$TASK_ID)
check_response STATUS

echo "GET USERS as USER"
STATUS=$(curl --write-out "%{http_code}\n" --silent --output response.json -H 'Authorization: Bearer '$USER_ACCESS_TOKEN -H 'Content-Type: application/json' $URL/users)
check_response STATUS

rm response.json
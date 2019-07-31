#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: user-functions.h [URL]"
    echo "       Run functional tests against a URL"
    echo "       For example, ./user-functions.sh http://localhost:9393/v1"
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

function check_204_response () {
    check_response $1 204
}


URL=$1
TIMESTAMP=`date +%s`

echo "Signup User$TIMESTAMP"
STATUS=$(curl $URL/signup -d '{ "username" : "User'$TIMESTAMP'", "password" : "bad password" }' --write-out "%{http_code}\n" --silent --output response.json)
check_200_response $STATUS

echo "Signin User$TIMESTAMP"
STATUS=$(curl $URL/signin -d '{ "username" : "User'$TIMESTAMP'", "password" : "bad password" }' --write-out "%{http_code}\n" --silent --output response.json)
check_200_response $STATUS
USER_ACCESS_TOKEN=`cat response.json`

echo "GET $URL/tasks as User$TIMESTAMP"
STATUS=$(curl $URL/tasks -H 'Authorization: Bearer '$USER_ACCESS_TOKEN --write-out "%{http_code}\n" --silent --output response.json)
check_200_response STATUS

echo "POST $URL/tasks as User$TIMESTAMP"
STATUS=$(curl $URL/tasks -d @create.json -H 'Authorization: Bearer '$USER_ACCESS_TOKEN --write-out "%{http_code}\n" --silent --output response.json)
check_200_response STATUS

echo "POST $URL/tasks as User$TIMESTAMP"
STATUS=$(curl $URL/tasks -d @create.json -H 'Authorization: Bearer '$USER_ACCESS_TOKEN --write-out "%{http_code}\n" --silent --output response.json)
check_200_response STATUS
TASK_ID=`jq -s -r .[0].id response.json`

echo "GET $URL/tasks/$TASK_ID as User$TIMESTAMP"
STATUS=$(curl $URL/tasks/$TASK_ID -H 'Authorization: Bearer '$USER_ACCESS_TOKEN --write-out "%{http_code}\n" --silent --output response.json)
check_200_response STATUS

echo "PUT $URL/tasks/$TASK_ID as User$TIMESTAMP"
STATUS=$(curl -X PUT $URL/tasks/$TASK_ID -d @update.json -H 'Authorization: Bearer '$USER_ACCESS_TOKEN --write-out "%{http_code}\n" --silent --output response.json)
check_200_response STATUS

echo "GET $URL/tasks/$TASK_ID/notes as User$TIMESTAMP"
STATUS=$(curl $URL/tasks/$TASK_ID/notes -H 'Authorization: Bearer '$USER_ACCESS_TOKEN --write-out "%{http_code}\n" --silent --output response.json)
check_200_response STATUS

echo "POST $URL/tasks/$TASK_ID/notes as User$TIMESTAMP"
STATUS=$(curl $URL/tasks/$TASK_ID/notes -d '{ "text" : "no man is an island" }' -H 'Authorization: Bearer '$USER_ACCESS_TOKEN --write-out "%{http_code}\n" --silent --output response.json)
check_200_response STATUS
NOTE_ID=`jq -s -r .[0].id response.json`

echo "POST $URL/tasks/$TASK_ID/notes as User$TIMESTAMP"
STATUS=$(curl $URL/tasks/$TASK_ID/notes -d '{ "text" : "white pepper" }' -H 'Authorization: Bearer '$USER_ACCESS_TOKEN --write-out "%{http_code}\n" --silent --output response.json)
check_200_response STATUS

echo "POST $URL/tasks/$TASK_ID/notes as User$TIMESTAMP"
STATUS=$(curl $URL/tasks/$TASK_ID/notes -d '{ "text" : "ice cream" }' -H 'Authorization: Bearer '$USER_ACCESS_TOKEN --write-out "%{http_code}\n" --silent --output response.json)
check_200_response STATUS

echo "PUT $URL/tasks/$TASK_ID/notes/$NOTE_ID as User$TIMESTAMP"
STATUS=$(curl -X PUT $URL/tasks/$TASK_ID/notes/$NOTE_ID -d '{ "text" : "foobar" }' -H 'Authorization: Bearer '$USER_ACCESS_TOKEN --write-out "%{http_code}\n" --silent --output response.json)
check_200_response STATUS

echo "GET $URL/tasks/$TASK_ID as User$TIMESTAMP"
STATUS=$(curl $URL/tasks/$TASK_ID -H 'Authorization: Bearer '$USER_ACCESS_TOKEN --write-out "%{http_code}\n" --silent --output response.json)
check_200_response STATUS

exit

echo ""
echo "=== TEST ONGOING TASK FEATURE ==="

echo "POST $URL/trackers as User$TIMESTAMP"
STATUS=$(curl -X POST $URL/trackers -H 'Authorization: Bearer '$USER_ACCESS_TOKEN --write-out "%{http_code}\n" --silent --output response.json)
check_200_response STATUS
TRACKER_ID=`jq -s -r .[0].id response.json`

echo "PUT $URL/trackers/$TRACKER_ID as User$TIMESTAMP"
STATUS=$(curl -X PUT $URL/trackers/$TRACKER_ID -H 'Authorization: Bearer '$USER_ACCESS_TOKEN --write-out "%{http_code}\n" --silent --output response.json)
check_200_response STATUS

echo "POST $URL/trackers as User$TIMESTAMP"
STATUS=$(curl -X POST $URL/trackers -H 'Authorization: Bearer '$USER_ACCESS_TOKEN --write-out "%{http_code}\n" --silent --output response.json)
check_200_response STATUS
TRACKER_ID=`jq -s -r .[0].id response.json`

echo "PUT $URL/trackers/$TRACKER_ID as User$TIMESTAMP"
STATUS=$(curl -X PUT $URL/trackers/$TRACKER_ID -H 'Authorization: Bearer '$USER_ACCESS_TOKEN --write-out "%{http_code}\n" --silent --output response.json)
check_200_response STATUS

echo ""
echo "=== TEST EXPORT FEATURE ==="

echo "GET $URL/tasks?format=html&from=2019-05-01 as User$TIMESTAMP"
STATUS=$(curl $URL/tasks?format=html\&from=2019-05-01 -H 'Authorization: Bearer '$USER_ACCESS_TOKEN --write-out "%{http_code}\n" --silent --output response.html)
check_200_response $STATUS

echo ""
echo "=== TEST DELETE ==="

echo "DELETE $URL/tasks/$TASK_ID/notes/$NOTE_ID as User$TIMESTAMP"
STATUS=$(curl -X DELETE $URL/tasks/$TASK_ID/notes/$NOTE_ID -H 'Authorization: Bearer '$USER_ACCESS_TOKEN --write-out "%{http_code}\n" --silent --output response.json)
check_204_response $STATUS

echo "GET $URL/tasks/$TASK_ID/notes as User$TIMESTAMP"
STATUS=$(curl $URL/tasks/$TASK_ID/notes -H 'Authorization: Bearer '$USER_ACCESS_TOKEN --write-out "%{http_code}\n" --silent --output response.json)
check_200_response $STATUS

echo "DELETE $URL/tasks/$TASK_ID as User$TIMESTAMP"
STATUS=$(curl -X DELETE $URL/tasks/$TASK_ID -H 'Authorization: Bearer '$USER_ACCESS_TOKEN --write-out "%{http_code}\n" --silent --output response.json)
check_204_response $STATUS

echo "GET $URL/users as User$TIMESTAMP"
STATUS=$(curl $URL/users -H 'Authorization: Bearer '$USER_ACCESS_TOKEN --write-out "%{http_code}\n" --silent --output response.json)
check_200_response $STATUS

rm response.json
rm response.html

echo ""
echo "=== FINISH ==="
# Time Tracker
Write an application for time management system

# Project Definition
* User must be able to create an account and log in. (If a mobile application, this means that more users can use the app from the same phone).
* User can add (and edit and delete) a row what he has worked on, what date, for how long.
* User can add a setting (Preferred working hours per day).
* If on a particular date a user has worked under the PreferredWorkingHourPerDay, these rows are red, otherwise green.
* Implement at least three roles with different permission levels: a regular user would only be able to CRUD on their owned records, a user manager would be able to CRUD users, and an admin would be able to CRUD all records and users.
* Add live tracking feature: a user can create an ongoing task, when the user marks the task as done, the duration is calculated automatically, and a new record gets added.
* Filter entries by date from-to.
* Export the filtered times to a sheet in HTML:
  * Date: 2018.05.21
  * Total time: 9h
  * Notes:
    * Note1
    * Note2
    * Note3
* New users need to verify their account by email. Users should not be able to log in until this verification is complete.
* Additionally, provide an option for the user to log in using at least two social media providers (you can pick from Google, Facebook, Twitter, Github, or similar).
* When a user fails to log in three times in a row, his or her account should be blocked automatically, and only admins and managers should be able to unblock it.
* An admin should be able to invite someone to the application by typing an email address in an input field; the system should then send an invitation message automatically, prompting the user to complete the registration.
* Users have to be able to upload and change their profile picture. If they log in using a social media pull the image from their account they used to log in.
* REST API. Make it possible to perform all user actions via the API, including authentication (If a mobile application and you don’t know how to create your own backend you can use Firebase.com or similar services to create the API).
* In any case, you should be able to explain how a REST API works and demonstrate that by creating functional tests that use the REST Layer directly. Please be prepared to use REST clients like Postman, cURL, etc. for this purpose.
* If it’s a web application, it must be a single-page application. All actions need to be done client side using AJAX, refreshing the page is not acceptable. (If a mobile application, disregard this).
* Functional UI/UX design is needed. You are not required to create a unique design, however, do follow best practices to make the project as functional as possible.
* Write unit and e2e tests.
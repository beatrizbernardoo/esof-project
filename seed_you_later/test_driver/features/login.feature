 Feature: Login
 Background: User is on the login page

   Scenario: User login successful
     Given the user wants to login
     When the user enters valid credentials and submits the login form
     Then the user should be successfully logged in
     And the user should be redirected to their home page

   Scenario: User login failed
     Given the user wants to login
     When the user enters invalid credentials and attempts to log in
     Then the user should receive an error message indicating login failure
     And the user should remain on the login page.
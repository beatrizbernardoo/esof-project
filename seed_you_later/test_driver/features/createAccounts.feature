 Feature: Create accounts
 Background: User is on the registration page

   Scenario: User successfully registers an account
     Given the user wants to register an account
     When the user enters valid registration details
     And clicks on the register button
     Then an account should be created for the user
    
   Scenario: User unsuccessfully registers an account
     Given the user wants to register an account
     When the user attempts to register with invalid or incomplete information
     Then they should see an error message indicating the reason for the   registration failure.
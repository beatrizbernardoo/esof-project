 Feature: Manage Profile
 Background: User is on the registration page

   Scenario: User updates profile information
     Given the user is logged in to their account
     When the user navigates to the profile settings
     And the user updates their profile information
     Then the user’s profile information should be updated.
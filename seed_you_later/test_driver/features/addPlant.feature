 Feature: Add plant

   Scenario: Add plant to collection
     Given the user is logged in to their account
     When the user clicks on “Add plant”
     And provides their species and name  
     Then the new plant should be added to the user’s collection.
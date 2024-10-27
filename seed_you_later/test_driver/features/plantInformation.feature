 Feature: Plant information
 
   Scenario: User wants to access plant information
     Given the user is on the plant information page
     When the user selects a specific plant
     Then the user should be able to view information about the selected plant

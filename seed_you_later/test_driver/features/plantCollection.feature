 Feature: Plant collection

   Scenario: View detailed information about each plant in the user’s collection
     Given the user is logged in and viewing their plant collection
     When the user selects a specific plant from their collection
     Then they should be able to view detailed information about that plant.
 Feature: Edit Plant Status

   Scenario: User wants to update plant status
     Given the user has a collection of plants
     When the user updates the status of a plant
     Then the user can review the updated status to identify any issues early on
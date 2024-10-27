 Feature: Remove Plant

   Scenario: Delete plant from collection
     Given the user is logged in to their account
     When the user selects a plant to delete
     Then the plant should be removed from the user’s collection
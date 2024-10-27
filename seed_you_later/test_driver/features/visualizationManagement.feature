 Feature: Visualization Management
 Background: A user with a collection of plants
 Given that the user is navigating on the page displaying their plant collection

   Scenario: User chooses predefined display option
     Given the user wants to customize plant data display options
     When the user chooses predefined
     Then the plants in their collection should be displayed by the order they were added

   Scenario: User chooses alphabetical display option
     Given the user wants to customize plant data display options
     When the user chooses alphabetical
     Then the plants in their collection should be displayed alphabetically
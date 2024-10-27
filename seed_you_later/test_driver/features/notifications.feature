 Feature: Notifications
 
   Scenario: User receives a notification for watering a plant
     Given the user has previously added plants to their collection
     When it is time to care for a specific plant according to its schedule
     Then the user should receive a notification reminding them to care for the plan

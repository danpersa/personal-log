Feature: The user activates the account
  As an user
  I want to activate my account
  So that i can access the application
  
  Scenario: The user successfully activates his account
    Given a user exists with an email of "brandon@example.com"
    And the following privacies exist:
    | Name     |
    | public   |
    | private  |
    When I go to the "brandon@example.com"'s activation page 
    Then I should see "Welcome to Remind Me To Live!"

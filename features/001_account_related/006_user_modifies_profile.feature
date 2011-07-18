Feature: 1.6 - The user modifies his profile
  As an user
  I want to change my profile details
  So that I can use my new email, nickname or picture

@focus
Scenario: The user successfully modifies his profile
    Given an user exists with an email of "brandon@example.com"
    And "brandon@example.com"'s the account is activated
    And the default privacies exist
    And I sign in with "brandon@example.com" and "foobar"
    When I go to the edit profile page of "brandon@example.com"
    And I fill in the following:
     | Name        | The User             |
     | Email       | user@yahoo.com       |
     | Location    | Bucharest            |
     | Website     | http://remindme.com  |
    And I press "Update public profile"
    Then I should see "Profile successfully updated"
    And "brandon@example.com"'s display name should be "The User"

Feature: 2.2 - The user follows another use
  As an user
  I want to follow another user
  So that I can see his last ideas

  Scenario: The user successfully follows another user
    Given a logged user with email "brandon@example.com"
    And "brandon@example.com"' has some reminders
    And the following user exists:
    | Name         | Email                |
    | FollowedUser | followed@example.com |
    And "followed@example.com"' has some reminders 
    When I go to the profile page of "followed@example.com"
    And I press "Follow"
    Then "brandon@example.com" should follow "followed@example.com"
    And I go to the home page
    And I should see "FollowedUser"

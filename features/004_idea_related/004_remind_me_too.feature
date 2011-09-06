Feature: 4.4 - The user shares another users's idea using the remind me too button
  As an user
  I want to use another users's idea
  So that other users can inspire me

  Scenario: The user successfully shares another user's idea from the home page
    Given a logged user with email "brandon@example.com"
    And "brandon@example.com" has a display name of "TheUser"
    And the following user exists:
    | Name          | Email              |
    | FirstUser     | first@example.com  |
    And "brandon@example.com" follows "first@example.com"
    And "first@example.com" shares 1 idea
    And I am on the home page
    When I follow "Remind me too"
    And I fill in "reminder_reminder_date" with "05/05/2020"
    And I press "Create reminder"
    Then I should see "Reminder successfully created!"
  
  Scenario: The user successfully shares another user's idea from another user's profile page
    Given a logged user with email "brandon@example.com"
    And "brandon@example.com" has a display name of "TheUser"
    And the following user exists:
    | Name          | Email              |
    | FirstUser     | first@example.com  |
    And "brandon@example.com" follows "first@example.com"
    And "first@example.com" shares 1 idea
    And I am on the profile page of "first@example.com"
    When I follow "Remind me too"
    And I fill in "reminder_reminder_date" with "05/05/2020"
    And I press "Create reminder"
    Then I should see "Reminder successfully created"



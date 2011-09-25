Feature: 2.8 - The user accesses another user's profile page
  As an user
  I want have access to another user's profile pages
  So that I can see their activity in the application
  And I can inspire from their ideas

  Scenario: The user successfully accesses another user's profile
    Given a logged user with email "brandon@example.com"
    And the following user exists:
    | Name         | Email                  |
    | AnotherUser  | another@example.com    |
    And "another@example.com"' has some reminders
    When I go to the profile page of "another@example.com"
    Then I should see "another@example.com"'s display name
    And I should see "...wants to remind to..."
    And I should see "Remind me too"
    And I should not see "Create new reminder"

  Scenario: The guest successfully accesses another user's profile
    Given the following user exists:
    | Name         | Email                  |
    | AnotherUser  | another@example.com    |
    And "another@example.com"' has some reminders
    When I go to the profile page of "another@example.com"
    Then I should see "another@example.com"'s display name
    And I should see "...wants to remind to..."
    And I should not see "Remind me too"
    And I should not see "Create new reminder"

  Scenario: The user successfully sees the 'Create new reminder' button for the ideas that he already shares
    Given a logged user with email "brandon@example.com"
    And the following user exists:
    | Name         | Email                  |
    | AnotherUser  | another@example.com    |
    And "brandon@example.com" shares 1 idea
    And "another@example.com" shares the same idea
    When I go to the profile page of "another@example.com"
    Then I should see "another@example.com"'s display name
    And I should see "...wants to remind to..."
    And I should see "Create new reminder"
Feature: 4.2 - The user can see all his ideas
  As an user
  I want to see all my ideas
  So that I can create new reminders for them
   - Or delete them
   - Or analyse if they are actual

  Scenario: The user successfully sees his ideas
    Given a logged user with email "brandon@example.com"
    And "brandon@example.com" shares some ideas
    When I go to the "brandon@example.com"'s ideas page
    Then I should see "brandon@example.com"'s display name
    Then I should see "...has the next ideas..."
    Then I should see "brandon@example.com"'s ideas content



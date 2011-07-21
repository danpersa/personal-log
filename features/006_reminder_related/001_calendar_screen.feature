Feature: 6.1 - The user sees all his reminders in a calendar screen
  As an user
  I want to see all my reminders grouped in a calendar
  So that I can be able to see the ideas I want to remember this month

  Scenario: The user successfully sees all his reminders in a calendar
    Given a logged user with email "brandon@example.com"
    And "brandon@example.com" shares 5 ideas on "10/10/2012"
    When I go to the calendar page on "2012-10"
    Then I should see "brandon@example.com"'s ideas content trimmed
    
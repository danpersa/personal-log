Feature: 6.2 - The user sees a menu in the calendar screen
  As an user
  I want to return to other pages in the website
  So that I can be able to navigate more quickly

  Scenario: The user successfully sees the menu in the calendar screen
    Given a logged user with email "brandon@example.com"
    When I go to the calendar page
    Then I should see "0 following"
    And I should see "0 followers"
    And I should see "0 ideas"
    And I should see "brandon@example.com"'s display name
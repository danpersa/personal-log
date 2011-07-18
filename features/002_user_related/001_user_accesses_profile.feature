Feature: 2.1 - The user accesses his profile page
  As an user
  I want have access to my profile page
  So that I can see my activity in the application

  @focus
  Scenario: The user successfully accesses his profile
    Given a logged user with email "brandon@example.com"
    And "brandon@example.com"' has some reminders
    When I go to the profile page of "brandon@example.com"
    Then I should see "brandon@example.com"'s name
    And I should see "...wants to remind to..."
    And I should see "Idea Lists"

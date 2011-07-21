Feature: 4.5 - The user sees all the users that have the same idea on his dashboard
  As an user
  I want to see the groups of users that I follow and use the same idea
   - Or groups of users that I don't follow, but share the same idea as me
  So that I can't miss interesting ideas

  Scenario: The user successfully sees a group of people that he follows and share the same idea
    Given a logged user with email "brandon@example.com"
    And the following user exists:
    | Name          | Email              |
    | FirstUser     | first@example.com  |
    | SecondUser    | second@example.com |
    And "first@example.com" shares 1 idea
    And "second@example.com" shares the same idea
    And "brandon@example.com" follows "second@example.com"
    When I go to the home page
    Then I should see "FirstUser"
    And I should see "SecondUser"
  
  Scenario: The user successfully sees a group of people that he does not follow but share the same idea as him
    Given a logged user with email "brandon@example.com"
    And "brandon@example.com" has a display name of "TheUser"
    And the following user exists:
    | Name          | Email              |
    | FirstUser     | first@example.com  |
    | SecondUser    | second@example.com |
    And "brandon@example.com" shares 1 idea
    And "first@example.com" shares the same idea
    And "second@example.com" shares the same idea
    When I go to the home page
    Then I should see "FirstUser"
    And I should see "1 other person"
    And I should see "TheUser"
  
  Scenario: The user does not see a group of people that he does not follow but share the same idea
    Given a logged user with email "brandon@example.com"
    And the following user exists:
    | Name          | Email              |
    | FirstUser     | first@example.com  |
    | SecondUser    | second@example.com |
    And "second@example.com" shares 1 idea
    And "first@example.com" shares the same idea
    When I go to the home page
    Then I should not see "FirstUser"
    And I should not see "SecondUser"
Feature: 4.3 - The user destroys one of his ideas
  As an user
  I want to destroy one of my ideas
  So that I can concentrate on implementing other ideas
  - Or I can remove ideas added by mistake
 
  Scenario: The user successfully donates to the community an idea shared with a group
    Given a logged user with email "brandon@example.com"
    And "brandon@example.com" has a display name of "TheUser"
    And the following user exists:
    | Name          | Email                        |
    | FirstUser     | first@example.com            |
    | SecondUser    | second@example.com           |
    | community     | community@remindmetolive.com |
    And "brandon@example.com" shares 1 idea
    And "first@example.com" shares the same idea
    And "second@example.com" shares the same idea
    When I go to the "brandon@example.com"'s ideas page
    And I follow "Remove idea"
    And I go to the profile page of "community@remindmetolive.com"
    Then I should see "1 idea"
    And I go to the "brandon@example.com"'s ideas page
    And I should see "0 ideas"

  Scenario: The user successfully destroys an idea
    Given a logged user with email "brandon@example.com"
    And "brandon@example.com" has a display name of "TheUser"
    And the following user exists:
    | Name          | Email                        |
    | SecondUser    | second@example.com           |
    | community     | community@remindmetolive.com |
    And "brandon@example.com" shares 1 idea
    When I go to the "brandon@example.com"'s ideas page
    And I follow "Remove idea"
    And I go to the profile page of "community@remindmetolive.com"
    Then I should see "0 idea"
    And I go to the "brandon@example.com"'s ideas page
    And I should see "0 ideas"